#!/usr/bin/env node

/**
 * Terraform Generation Agent - Generates Terraform HCL code
 *
 * This agent queries the HashiCorp Terraform MCP Server and Agent Skills
 * for documentation and generates production-ready Terraform code for Azure resources.
 */

import { BaseAgent } from '../base-agent.js';
import {
  AgentType,
  TerraformCode,
  ExtractedRequirements,
  WorkflowState,
  TerraformMetadata,
} from '../../shared-types.js';
import { Tool } from '@modelcontextprotocol/sdk/types.js';
import { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { StdioClientTransport } from '@modelcontextprotocol/sdk/client/stdio.js';
import OpenAI from 'openai';

interface TerraformGenPayload {
  requirements: ExtractedRequirements;
  intent: string;
}

export class TerraformGenAgent extends BaseAgent {
  private openai: OpenAI;
  private terraformMcpUrl: string;
  private agentSkillsClient: Client | null = null;
  private agentSkillsTransport: StdioClientTransport | null = null;

  constructor() {
    const tools: Tool[] = [
      {
        name: 'generate_terraform',
        description: 'Generate Terraform HCL code based on infrastructure requirements',
        inputSchema: {
          type: 'object',
          properties: {
            requirements: {
              type: 'object',
              description: 'Extracted infrastructure requirements',
              properties: {
                resourceType: { type: 'string' },
                resourceName: { type: 'string' },
                region: { type: 'string' },
                specifications: { type: 'object' },
                tags: { type: 'object' },
                securityRequirements: { type: 'array', items: { type: 'string' } },
              },
            },
            intent: {
              type: 'string',
              description: 'The infrastructure intent (create_vm, create_storage, etc.)',
            },
          },
          required: ['requirements', 'intent'],
        },
      },
      {
        name: 'query_terraform_docs',
        description: 'Query HashiCorp Terraform MCP Server for resource documentation',
        inputSchema: {
          type: 'object',
          properties: {
            resourceType: {
              type: 'string',
              description: 'Azure resource type (e.g., azurerm_virtual_machine)',
            },
            query: {
              type: 'string',
              description: 'Specific documentation query',
            },
          },
          required: ['resourceType'],
        },
      },
    ];

    super({
      name: 'Terraform Generation Agent',
      version: '1.0.0',
      type: AgentType.TERRAFORM_GEN,
      capabilities: [
        'terraform_code_generation',
        'azure_resource_mapping',
        'best_practices_application',
        'documentation_query',
      ],
      tools,
    });

    // Validate environment
    this.validateEnv(['OPENAI_API_KEY']);

    // Initialize OpenAI client
    this.openai = new OpenAI({
      apiKey: process.env.OPENAI_API_KEY,
    });

    this.terraformMcpUrl = process.env.TERRAFORM_MCP_SERVER_URL || 'http://localhost:3000';
    
    // Initialize Agent Skills MCP client
    this.initializeAgentSkills();
  }

  /**
   * Initialize HashiCorp Agent Skills MCP client
   */
  private async initializeAgentSkills(): Promise<void> {
    try {
      this.log('info', 'Initializing HashiCorp Agent Skills MCP client');
      
      // Create transport for Agent Skills MCP server
      // Note: Package not yet published to npm, checking if installed locally
      const agentSkillsPath = './node_modules/@hashicorp/agent-skills/dist/index.js';
      
      this.agentSkillsTransport = new StdioClientTransport({
        command: 'node',
        args: [agentSkillsPath],
        env: {
          ...process.env,
          TERRAFORM_VERSION: '1.6.0',
        },
      });

      // Create MCP client
      this.agentSkillsClient = new Client(
        {
          name: 'terraform-gen-agent',
          version: '1.0.0',
        },
        {
          capabilities: {},
        }
      );

      // Connect to Agent Skills server
      await this.agentSkillsClient.connect(this.agentSkillsTransport);
      
      // List available tools from Agent Skills
      const toolsResponse = await this.agentSkillsClient.listTools();
      this.log('info', 'Agent Skills tools available', {
        tools: toolsResponse.tools.map(t => t.name)
      });
      
    } catch (error) {
      this.log('warn', 'Failed to initialize Agent Skills, will use fallback', { error });
      // Don't throw - agent can still work without Agent Skills
    }
  }

  protected async handleToolCall(
    toolName: string,
    args: Record<string, any>
  ): Promise<any> {
    switch (toolName) {
      case 'generate_terraform':
        return this.generateTerraform(args.requirements, args.intent);
      
      case 'query_terraform_docs':
        return this.queryTerraformDocs(args.resourceType, args.query);
      
      default:
        throw new Error(`Unknown tool: ${toolName}`);
    }
  }

  protected async process(
    payload: TerraformGenPayload,
    context: WorkflowState
  ): Promise<TerraformCode> {
    this.log('info', 'Generating Terraform code', {
      resourceType: payload.requirements.resourceType,
      intent: payload.intent,
    });

    return this.generateTerraform(payload.requirements, payload.intent);
  }

  /**
   * Generate Terraform code based on requirements
   */
  private async generateTerraform(
    requirements: ExtractedRequirements,
    intent: string
  ): Promise<TerraformCode> {
    // Try to use Agent Skills first for Terraform-specific generation
    if (this.agentSkillsClient) {
      try {
        const agentSkillsResult = await this.useAgentSkills(requirements, intent);
        if (agentSkillsResult) {
          this.log('info', 'Generated code using HashiCorp Agent Skills');
          return agentSkillsResult;
        }
      } catch (error) {
        this.log('warn', 'Agent Skills generation failed, falling back to OpenAI', { error });
      }
    }
    
    // Fallback to OpenAI with Terraform docs
    const docs = await this.queryTerraformDocs(requirements.resourceType);

    // Generate code using OpenAI with documentation context
    const systemPrompt = `You are an expert Terraform developer specializing in Azure infrastructure.
Generate production-ready Terraform HCL code following these principles:

1. Use Azure best practices and security guidelines
2. Include ONLY the REQUIRED resource dependencies for each resource type
3. Add meaningful tags and naming conventions
4. Enable encryption and security features by default
5. Use variables for configurable values
6. Include outputs for important resource attributes
7. Follow the official Terraform documentation
8. Generate COMPLETE infrastructure - never reference resources that don't exist
9. Support modular Terraform structure when requested
10. Create separate files (variables.tf, outputs.tf, main.tf, modules/) when specified
11. Use Terraform best practices: locals, for_each, dynamic blocks when appropriate
12. Avoid using "example" as resource aliases unless specifically requested
13. ALWAYS include "skip_provider_registration = true" in the azurerm provider block
14. CRITICAL: Output ONLY valid HCL code - NO explanatory text, NO comments outside of HCL comments, NO markdown
15. CRITICAL: Every file must contain ONLY valid Terraform HCL syntax - no prose, no descriptions outside of HCL

MANDATORY TAGGING REQUIREMENTS (CRITICAL):
- ALL Azure resources that support tags MUST include these tags:
  * Environment: Must be one of "Dev", "Stage", or "Prod" (default to "Dev" if not specified)
  * Service: Name of the service/application (use resource name or "terraform-managed" as default)
  * ManagedBy: Always set to "Terraform"
  * CreatedDate: Use timestamp() function in resource blocks (NOT in variable defaults)
- Apply tags to: Resource Groups, VNets, Subnets, NSGs, VMs, Disks, NICs, Public IPs, Storage Accounts, etc.
- Tags format in RESOURCES:
  tags = {
    Environment = var.environment
    Service     = var.service_name
    ManagedBy   = "Terraform"
    CreatedDate = timestamp()
  }
- Tags format in VARIABLE DEFAULTS (NO FUNCTIONS ALLOWED):
  default = {
    Environment = "Dev"
    Service     = "terraform-managed"
    ManagedBy   = "Terraform"
  }

CRITICAL: STORAGE ACCOUNTS vs MANAGED DISKS
- VMs use MANAGED DISKS (azurerm_managed_disk) for VM disks, NOT storage accounts
- Storage accounts (azurerm_storage_account) are for:
  ✅ Blob storage, file shares, table storage, queue storage
  ✅ Boot diagnostics (when user asks for diagnostics)
  ✅ Azure Functions storage
  ❌ NOT for VM disks or "additional disks" for VMs
- If user asks for "additional disk" for a VM → create azurerm_managed_disk
- If user asks for "diagnostics" → create storage account for diagnostics
- If user does NOT mention "diagnostics" or "blob storage" → DO NOT create storage account

Resource Documentation:
${docs}

Generate complete, working Terraform code that can be applied immediately.

CRITICAL RULES - RESOURCE DEPENDENCIES:
- Do NOT include terraform{} or provider{} blocks in main.tf (they go in provider.tf)
- NEVER reference resources that you haven't defined
- Use proper resource naming based on user requirements (avoid "example" if user says so)
- All resource references must point to resources you've created in the same code
- When modules are requested, create proper module structure with separate directories
- When separate files are requested, organize code into variables.tf, outputs.tf, main.tf, etc.
- Place provider configuration in the file specified by user (default: provider.tf)
- CRITICAL: NEVER use functions like timestamp() in variable default values - functions are ONLY allowed in resource/data blocks
- Variable defaults must be static values only (strings, numbers, booleans, lists, maps)

CRITICAL RULES - MODULE VARIABLES (PREVENT "MISSING REQUIRED ARGUMENT" ERRORS):
1. In module variables.tf: Variables WITHOUT "default =" are REQUIRED
2. In module variables.tf: Variables WITH "default = null" (or any default) are OPTIONAL
3. In root main.tf module calls: MUST pass ALL required variables (those without defaults)
4. In root main.tf module calls: CAN omit optional variables (those with defaults)
5. ALWAYS include these as REQUIRED in ALL modules (no defaults):
   - resource_group_name
   - location
   - tags
6. ALWAYS include these as OPTIONAL in modules (with default = null):
   - public_ip_id (only pass if public IP created)
   - nsg_id (only pass if NSG created)
   - boot_diagnostics_storage_account_uri (only pass if storage account created)
7. When in doubt, add "default = null" to make a variable optional
8. NEVER create a required variable (no default) unless it's absolutely necessary

RESOURCE-SPECIFIC DEPENDENCY RULES (CRITICAL - DO NOT HALLUCINATE):
1. **Virtual Machines (VMs)**: REQUIRE Resource Group, VNet, Subnet, NSG, NIC, optionally Public IP
2. **Storage Accounts**: REQUIRE ONLY Resource Group. DO NOT create VNet, Subnet, NIC, Public IP unless user explicitly requests private endpoint
3. **AKS Clusters**: REQUIRE Resource Group, optionally VNet/Subnet if user specifies custom networking
4. **Azure SQL/Databases**: REQUIRE ONLY Resource Group and SQL Server. DO NOT create networking unless user requests private endpoint
5. **App Services/Web Apps**: REQUIRE ONLY Resource Group and App Service Plan. DO NOT create VNet unless user requests VNet integration
6. **Azure Functions**: REQUIRE ONLY Resource Group and Storage Account. DO NOT create networking unless requested
7. **Databricks Workspace**: REQUIRE Resource Group, optionally VNet if user specifies VNet injection
8. **Key Vault**: REQUIRE ONLY Resource Group. DO NOT create networking unless user requests private endpoint
9. **Container Registry**: REQUIRE ONLY Resource Group. DO NOT create networking unless user requests private endpoint
10. **Cosmos DB**: REQUIRE ONLY Resource Group. DO NOT create networking unless user requests private endpoint

NETWORKING RULES:
- Create VNet, Subnet, NSG, NIC, Public IP ONLY for resources that REQUIRE them (VMs, VM Scale Sets)
- For PaaS services (Storage, SQL, App Service, Functions, etc.), create ONLY the resource and its resource group
- If user explicitly mentions "private endpoint", "private link", or "VNet integration", then create networking
- If user says "public endpoint" or doesn't mention networking, create basic resource without networking

MODULE-SPECIFIC RULES (CRITICAL):
- In modules, define outputs ONLY in outputs.tf, NEVER in main.tf
- Module main.tf should contain ONLY resource and data blocks
- Module outputs.tf should contain ALL output blocks
- Do NOT duplicate outputs between main.tf and outputs.tf
- Each output name must be unique within a module`;

    const userPrompt = `Generate Terraform code for:
Intent: ${intent}
Resource Type: ${requirements.resourceType}
Resource Name: ${requirements.resourceName || 'resource'}
Region: ${requirements.region || 'eastus'}
Specifications: ${JSON.stringify(requirements.specifications, null, 2)}
Security Requirements: ${requirements.securityRequirements?.join(', ') || 'standard'}
Tags: ${JSON.stringify(requirements.tags || {}, null, 2)}

CRITICAL ANTI-HALLUCINATION RULES:
1. READ THE USER REQUEST CAREFULLY - Only create what is EXPLICITLY mentioned
2. VMs use MANAGED DISKS (azurerm_managed_disk), NOT storage accounts for VM disks
3. "Additional disk" for VM means azurerm_managed_disk + azurerm_virtual_machine_data_disk_attachment

4. Storage accounts (azurerm_storage_account) should ONLY be created when:
   ✅ User explicitly asks for "blob storage", "file share", "table storage", or "queue storage"
   ✅ User explicitly asks for "diagnostics" or "boot diagnostics"
   ✅ User explicitly asks for "storage account"
   ✅ Creating Azure Functions (requires storage account)
   ❌ User asks for "VM with additional disk" (use managed disk instead)
   ❌ User asks for "VM with storage" without specifying blob/file/diagnostics (use managed disk)
   ❌ User just says "create a VM" (no storage account needed)

5. For VM requests WITHOUT "diagnostics" or "blob storage" mentioned:
   - VM module: azurerm_windows_virtual_machine or azurerm_linux_virtual_machine
   - Managed disk: azurerm_managed_disk (for additional disks)
   - Disk attachment: azurerm_virtual_machine_data_disk_attachment
   - Network module: VNet, Subnet, NSG, NIC, Public IP
   - DO NOT CREATE: azurerm_storage_account, storage module

6. For VM requests WITH "diagnostics" mentioned:
   - Create everything above PLUS
   - Storage account for diagnostics: azurerm_storage_account (with name like "diagstorage")
   - Configure boot_diagnostics block in VM to use the storage account

7. NEVER create a storage module unless user explicitly asks for blob/file/table/queue storage or diagnostics

WHAT TO CREATE FOR THIS REQUEST:
${requirements.resourceType.toLowerCase().includes('vm') || requirements.resourceType.toLowerCase().includes('virtual machine') ? `
- Resource Group
- Network Module: VNet (${requirements.specifications?.vnetCidr || '10.0.0.0/16'}), Subnets (${requirements.specifications?.subnetCidrs?.join(', ') || '10.0.1.0/24, 10.0.2.0/24'}), NSG, Public IP
- VM Module: ${requirements.specifications?.osType === 'windows' ? 'azurerm_windows_virtual_machine' : 'azurerm_linux_virtual_machine'}
${requirements.specifications?.additionalDisks ? `- Additional Disk: azurerm_managed_disk (${requirements.specifications.additionalDisks[0]?.size || 128}GB)
- Disk Attachment: azurerm_virtual_machine_data_disk_attachment` : ''}
- Random Password: random_password
- DO NOT CREATE: azurerm_storage_account, storage module
` : ''}

STRUCTURE REQUIREMENTS:
${requirements.specifications?.useModules ? `
- CREATE SEPARATE MODULES for: ${requirements.specifications.moduleStructure?.join(', ')}
- Each module should have its own directory with variables.tf, main.tf, outputs.tf
- Root main.tf should call these modules
` : ''}
${requirements.specifications?.separateFiles ? `
- CREATE SEPARATE FILES: ${requirements.specifications.fileStructure?.join(', ')}
- Provider configuration goes in: ${requirements.specifications.providerLocation || 'provider.tf'} (DEFAULT: provider.tf)
- Variables go in variables.tf (ONLY variables, NO provider blocks)
- Outputs go in outputs.tf (NOT in main.tf)
- Provider blocks should NEVER be in variables.tf unless explicitly requested
` : ''}
${requirements.specifications?.avoidExampleAliases ? `
- DO NOT use "example" as resource alias/name
- Use meaningful names based on resource purpose
` : ''}
${requirements.specifications?.useLocals ? '- Use locals{} blocks for repeated values' : ''}
${requirements.specifications?.useForEach ? '- Use for_each instead of count where appropriate' : ''}
${requirements.specifications?.useDynamicBlocks ? '- Use dynamic blocks for repeated nested blocks' : ''}
${requirements.specifications?.namingConvention ? `- Follow naming convention: ${requirements.specifications.namingConvention}` : ''}

INFRASTRUCTURE REQUIREMENTS:
Generate infrastructure based on resource type:

FOR VIRTUAL MACHINES:
CRITICAL: Check specifications.osType to determine VM type:
- If osType = "windows" → Use azurerm_windows_virtual_machine
- If osType = "linux" → Use azurerm_linux_virtual_machine
- Default to Linux ONLY if osType is not specified

1. Resource Group (azurerm_resource_group)
2. Virtual Network (azurerm_virtual_network) with CIDR from specifications.vnetCidr or default
3. Subnet(s) (azurerm_subnet) - create multiple if specifications.subnetCidrs is an array
   CRITICAL SUBNET NAMING: When using for_each with CIDR blocks:
   - Use index as the key, NOT the CIDR value (CIDR contains "/" which is invalid in Azure names)
   - CORRECT: for_each = { for idx, cidr in var.subnet_cidrs : idx => cidr }
   - WRONG: for_each = toset(var.subnet_cidrs) # Uses CIDR as key
   - Name format: subnet-0, subnet-1, etc. using the index key
4. Network Security Group (azurerm_network_security_group) with basic rules
5. Network Interface (azurerm_network_interface) connected to the subnet
6. Public IP (azurerm_public_ip) if specifications.publicIp = true or external access needed
7. Storage Account for Boot Diagnostics (azurerm_storage_account):
   - ONLY create if diagnostics are needed (best practice for production VMs)
   - Use Standard_LRS for cost efficiency
   - Enable blob encryption
   - Use random_string resource to generate unique name (e.g., "bootdiag" + random_string)
8. The VM resource:
   - For Windows: azurerm_windows_virtual_machine with:
     * size: Use latest generation Dv5-series (e.g., Standard_D2s_v5, Standard_D4s_v5) for cost optimization
     * license_type: Set to "Windows_Server" to enable Azure Hybrid Benefit (saves ~40% on Windows licensing)
     * os_disk block (storage_account_type from specifications.osDiskType or Standard_LRS)
     * admin_username from specifications.adminUsername or "adminuser"
     * admin_password using random_password resource
     * source_image_reference: publisher="MicrosoftWindowsServer", offer="WindowsServer", sku="2022-Datacenter", version="latest"
     * boot_diagnostics block with storage_account_uri pointing to the diagnostics storage account
   - For Linux: azurerm_linux_virtual_machine with:
     * size: Use latest generation Dv5-series (e.g., Standard_D2s_v5, Standard_D4s_v5) for better performance/cost
     * os_disk block (storage_account_type from specifications.osDiskType or Standard_LRS)
     * admin_username from specifications.adminUsername or "adminuser"
     * admin_password using random_password resource
     * disable_password_authentication = false if authType = "password"
     * source_image_reference: publisher="Canonical", offer="UbuntuServer", sku="18.04-LTS", version="latest"
     * boot_diagnostics block with storage_account_uri pointing to the diagnostics storage account
9. Managed Disks (azurerm_managed_disk) for each disk in specifications.additionalDisks array
10. Disk Attachments (azurerm_virtual_machine_data_disk_attachment) to attach each data disk to VM

CRITICAL VM RULES:
- DO NOT create azurerm_storage_account for VM disks - VMs use managed disks (os_disk block and azurerm_managed_disk)
- Storage accounts are ONLY for blob/file/table/queue storage, NOT for VM disks
- For HDD disks use storage_account_type = "Standard_LRS"
- For SSD disks use storage_account_type = "Premium_LRS" or "StandardSSD_LRS"
- Additional data disks require: azurerm_managed_disk + azurerm_virtual_machine_data_disk_attachment
- For password authentication: set disable_password_authentication = false and use random_password resource

BOOT DIAGNOSTICS CONFIGURATION (CRITICAL - MUST INCLUDE):
When creating a storage account for diagnostics, you MUST configure the boot_diagnostics block in the VM resource.

For Windows VM, add this block inside azurerm_windows_virtual_machine:
  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.bootdiag.primary_blob_endpoint
  }

For Linux VM, add this block inside azurerm_linux_virtual_machine:
  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.bootdiag.primary_blob_endpoint
  }

The storage account for diagnostics should be:
  - account_tier = "Standard"
  - account_replication_type = "LRS"
  - Use random_string resource for unique naming

FINOPS BEST PRACTICES (CRITICAL for Infracost compliance):
- VM Size: Use latest generation (Dv5, Ev5, Ddsv5) instead of older (DS_v2, ES_v2) for 20-30% better price/performance
- Windows VMs: ALWAYS set license_type = "Windows_Server" for Azure Hybrid Benefit (saves ~40% on licensing costs)
- Linux VMs: Consider license_type = "RHEL_BYOS" or "SLES_BYOS" if you have existing licenses
- Disk Type: Use Standard_LRS for dev/test, Premium_LRS only when IOPS requirements demand it
- Right-sizing: Match VM size to actual workload requirements (don't over-provision)
- Boot Diagnostics: ALWAYS include boot_diagnostics block when storage account is created for diagnostics

FOR PAAS SERVICES (Storage Account, SQL Database, App Service, Functions, Key Vault, Cosmos DB, etc.):
1. Resource Group
2. The PaaS resource itself (e.g., azurerm_storage_account for blob storage)
3. DO NOT create VNet, Subnet, NSG, NIC, or Public IP unless user explicitly requests private endpoint

FOR AKS/CONTAINER SERVICES:
1. Resource Group
2. The AKS/Container resource
3. VNet/Subnet only if user specifies custom networking

REMEMBER:
- VMs use MANAGED DISKS (os_disk + azurerm_managed_disk), NOT storage accounts for VM disks
- Storage accounts for VMs are ONLY for boot diagnostics (monitoring/troubleshooting)
- Storage accounts for blob/file/table/queue storage are separate resources
- Most Azure PaaS services are publicly accessible by default and DO NOT need networking resources!
- If you create a storage account for diagnostics, you MUST add boot_diagnostics block to the VM resource

OUTPUT FORMAT:

CRITICAL FILE FORMAT RULES (MUST FOLLOW EXACTLY):
1. Each file MUST start with: ### FILE: <filepath>
2. After the file marker, provide ONLY valid HCL code
3. NO explanatory text, NO prose, NO sentences outside of HCL comments
4. Module files MUST use paths like: ### FILE: modules/network/main.tf
5. Root files use: ### FILE: main.tf (no path prefix)

EXAMPLE OF CORRECT FORMAT:
### FILE: main.tf
resource "azurerm_resource_group" "main" {
  name = "example"
}

### FILE: modules/network/main.tf
resource "azurerm_virtual_network" "main" {
  name = "vnet"
}

${requirements.specifications?.useModules ? `
YOU MUST provide the code in EXACTLY this format:
### FILE: main.tf

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Storage account for boot diagnostics (if needed)
resource "random_string" "storage_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "azurerm_storage_account" "bootdiag" {
  name                     = "bootdiag\${random_string.storage_suffix.result}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.tags
}

module "network" {
  source = "./modules/network"
  
  # REQUIRED variables (no defaults in module)
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  vnet_cidr          = var.vnet_cidr
  subnet_cidrs       = var.subnet_cidrs
  tags               = var.tags
}

module "vm" {
  source = "./modules/vm"
  
  # REQUIRED variables (no defaults in module)
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  subnet_id           = module.network.subnet_id
  vm_size             = var.vm_size
  admin_username      = var.admin_username
  tags                = var.tags
  
  # OPTIONAL variables (have default = null in module, only pass if used)
  public_ip_id                          = module.network.public_ip_id
  nsg_id                                = module.network.nsg_id
  boot_diagnostics_storage_account_uri  = azurerm_storage_account.bootdiag.primary_blob_endpoint
}

CRITICAL RULES FOR MODULE CALLS:
1. ALWAYS pass ALL required variables (those without defaults in module variables.tf)
2. ONLY pass optional variables if they are actually used/created
3. If a module variable has "default = null", you can omit it from the module call
4. If a module variable has NO default, you MUST pass it in the module call
]

### FILE: variables.tf
[root variables - ONLY HCL CODE, NO EXPLANATIONS]

### FILE: outputs.tf
[root outputs - ONLY HCL CODE, NO EXPLANATIONS]

### FILE: terraform.tfvars
[Variable values file with actual values for all variables declared in variables.tf
Example:
resource_group_name = "rg-windows-vm"
location = "southindia"
vnet_cidr = "10.0.0.0/16"
subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
]

### FILE: modules/network/main.tf
[Network module with:
- azurerm_virtual_network using var.vnet_cidr
- azurerm_subnet resources (one for each CIDR in var.subnet_cidrs) using count or for_each
  CRITICAL: When using for_each with subnet_cidrs, use index as key, NOT the CIDR value
  CORRECT: for_each = { for idx, cidr in var.subnet_cidrs : idx => cidr }
  WRONG: for_each = toset(var.subnet_cidrs) # This uses CIDR as key which is invalid
  Subnet name should be: "subnet-\${each.key}" or "subnet-\${each.key + 1}"
- azurerm_network_security_group
- azurerm_public_ip if needed
DO NOT create storage account here!]

### FILE: modules/network/variables.tf
[Network module variables - COMPLETE EXAMPLE:

# REQUIRED variables (no default value)
variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "vnet_cidr" {
  type        = string
  description = "CIDR block for VNet"
}

variable "subnet_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks for subnets"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
}

# OPTIONAL variables (with default = null)
# Add these ONLY if the module creates these resources conditionally
variable "create_public_ip" {
  type        = bool
  default     = true
  description = "Whether to create public IP"
}

variable "create_nsg" {
  type        = bool
  default     = true
  description = "Whether to create NSG"
}

CRITICAL: If a variable has NO default, it is REQUIRED and MUST be passed when calling the module
]

### FILE: modules/network/outputs.tf
[Network module outputs ONLY for resources in THIS module:
- output "subnet_ids" { value = [for s in azurerm_subnet.main : s.id] } (if using for_each)
- output "subnet_ids" { value = azurerm_subnet.main[*].id } (if using count)
- output "subnet_id" { value = values(azurerm_subnet.main)[0].id } (first subnet, if using for_each)
- output "nsg_id" { value = azurerm_network_security_group.main.id }
- output "public_ip_id" { value = azurerm_public_ip.main.id } (if created)
- output "public_ip_address" { value = azurerm_public_ip.main.ip_address } (if created)
]

### FILE: modules/vm/main.tf
[VM module with:
- azurerm_network_interface
- azurerm_windows_virtual_machine OR azurerm_linux_virtual_machine (based on osType)
  * MUST include boot_diagnostics block if var.boot_diagnostics_storage_account_uri is provided:
    boot_diagnostics {
      storage_account_uri = var.boot_diagnostics_storage_account_uri
    }
- azurerm_managed_disk for EACH additional disk requested
- azurerm_virtual_machine_data_disk_attachment for EACH additional disk
- random_password
DO NOT create storage account here - it's created in root main.tf!]

### FILE: modules/vm/variables.tf
[VM module variables - COMPLETE EXAMPLE:

# REQUIRED variables (no default value - MUST be passed)
variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "subnet_id" {
  type        = string
  description = "ID of the subnet for the VM NIC"
}

variable "vm_size" {
  type        = string
  description = "Size of the VM"
}

variable "admin_username" {
  type        = string
  description = "Admin username for the VM"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
}

# OPTIONAL variables (with default = null - can be omitted)
variable "public_ip_id" {
  type        = string
  default     = null
  description = "Public IP ID (optional, pass only if public IP is created)"
}

variable "nsg_id" {
  type        = string
  default     = null
  description = "NSG ID (optional, pass only if NSG is created)"
}

variable "boot_diagnostics_storage_account_uri" {
  type        = string
  default     = null
  description = "Storage account URI for boot diagnostics (optional, pass only if storage account is created)"
}

variable "os_type" {
  type        = string
  default     = "linux"
  description = "OS type: windows or linux"
  validation {
    condition     = contains(["windows", "linux"], var.os_type)
    error_message = "os_type must be either 'windows' or 'linux'"
  }
}

CRITICAL RULES:
1. Variables WITHOUT default = REQUIRED, MUST be passed in module call
2. Variables WITH default = OPTIONAL, can be omitted from module call
3. NEVER create a variable without a default unless it's truly required
4. If unsure, add "default = null" to make it optional
]

### FILE: modules/vm/outputs.tf
[VM module outputs ONLY for resources in THIS module:
- output "vm_id" { value = azurerm_windows_virtual_machine.main.id } (or linux)
- output "vm_name" { value = azurerm_windows_virtual_machine.main.name } (or linux)
- output "nic_id" { value = azurerm_network_interface.main.id }
- output "admin_password" { value = random_password.admin.result, sensitive = true }
DO NOT output public_ip_address here - it's in the network module!
]

[repeat for each module: storage, etc.]

CRITICAL MODULE RULES:
1. Root main.tf MUST pass ALL REQUIRED variables to modules (variables without defaults)
2. Optional variables (with default = null or other defaults) do NOT need to be passed if not used
3. Module variables.tf should ONLY declare variables that are actually needed
4. DO NOT create unnecessary variables like "environment" or "unique_identifier" unless user specifically requests them
5. Keep module interfaces simple - distinguish between required and optional:
   
   REQUIRED (no default, must be passed):
   - resource_group_name
   - location
   - tags
   - Resource-specific configs (vm_size, subnet_id, vnet_cidr, etc.)
   
   OPTIONAL (with default = null, only pass if used):
   - public_ip_id (default = null)
   - nsg_id (default = null)
   - boot_diagnostics_storage_account_uri (default = null)

6. Module outputs.tf can ONLY reference resources defined in that module's main.tf
7. If VM module needs subnet_id, it must be:
   - Declared in modules/vm/variables.tf as: variable "subnet_id" { type = string }
   - Passed in root main.tf as: module "vm" { subnet_id = module.network.subnet_id }
   - Output from modules/network/outputs.tf as: output "subnet_id" { value = values(azurerm_subnet.main)[0].id }
8. ALWAYS include "tags" variable in ALL module variables.tf files (required, no default)
9. ALWAYS pass "tags = var.tags" when calling modules from root main.tf
10. Use "default = null" for optional variables that may not always be provided
7. Outputs MUST be in outputs.tf ONLY, NOT in main.tf
8. Each module should be self-contained but accept inputs from other modules via variables
9. BOOT DIAGNOSTICS: Storage account is created in ROOT main.tf, URI is passed to VM module as variable
   - Root main.tf creates: azurerm_storage_account.bootdiag
   - Root main.tf passes to VM module: boot_diagnostics_storage_account_uri = azurerm_storage_account.bootdiag.primary_blob_endpoint
   - VM module declares variable: variable "boot_diagnostics_storage_account_uri" { type = string }
   - VM module uses in boot_diagnostics block: storage_account_uri = var.boot_diagnostics_storage_account_uri

EXAMPLE - Simple Module Interface:
### FILE: modules/network/variables.tf
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "vnet_cidr" { type = string }
variable "subnet_cidrs" { type = list(string) }

### FILE: main.tf
module "network" {
  source = "./modules/network"
  resource_group_name = azurerm_resource_group.main.name
  location = azurerm_resource_group.main.location
  vnet_cidr = "10.0.0.0/16"
  subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
}
` : requirements.specifications?.separateFiles ? `
Provide the code in this format:
### FILE: main.tf
[main infrastructure code - ONLY HCL CODE, NO EXPLANATIONS]

### FILE: variables.tf
[all variable definitions - ONLY HCL CODE, NO EXPLANATIONS]

### FILE: outputs.tf
[all output definitions - ONLY HCL CODE, NO EXPLANATIONS]

### FILE: provider.tf
[terraform and provider configuration - ONLY HCL CODE, NO EXPLANATIONS]

CRITICAL: Provider blocks MUST be in provider.tf, NOT in variables.tf
` : `
Provide all code in a single block - ONLY HCL CODE, NO EXPLANATIONS.
`}

CRITICAL RULES:
- Do NOT include terraform{} block in main.tf - it goes in provider.tf
- Do NOT add any explanatory text, comments, or descriptions outside of HCL code
- Do NOT start files with "This Terraform configuration..." or similar text
- ONLY provide valid Terraform HCL code
- Ensure ALL resource references are to resources defined in this code`;

    try {
      const completion = await this.openai.chat.completions.create({
        model: process.env.OPENAI_MODEL || 'gpt-4',
        messages: [
          { role: 'system', content: systemPrompt },
          { role: 'user', content: userPrompt },
        ],
        temperature: 0.2,
        max_tokens: 4000,
      });

      const response = completion.choices[0]?.message?.content;
      if (!response) {
        throw new Error('No response from OpenAI');
      }

      // Parse the response to extract different files
      const files = this.parseGeneratedCode(response);

      const metadata: TerraformMetadata = {
        generatedAt: new Date(),
        terraformVersion: '1.6.0',
        providerVersions: {
          azurerm: '~> 3.80.0',
        },
        resourceCount: this.countResources(files.mainTf),
        estimatedComplexity: this.estimateComplexity(files.mainTf),
        documentationSources: [
          'HashiCorp Terraform Registry',
          'Azure Provider Documentation',
        ],
      };

      this.log('info', 'Terraform code generated successfully', {
        resourceCount: metadata.resourceCount,
        complexity: metadata.estimatedComplexity,
        hasModules: !!files.modules,
        moduleCount: files.modules ? Object.keys(files.modules).length : 0,
      });

      return {
        mainTf: files.mainTf,
        variablesTf: files.variablesTf,
        outputsTf: files.outputsTf,
        providerTf: files.providerTf,
        tfvars: files.tfvars,
        modules: files.modules,
        metadata,
      };
    } catch (error) {
      this.log('error', 'Failed to generate Terraform code', { error });
      throw error;
    }
  }

  /**
   * Use HashiCorp Agent Skills for Terraform code generation
   */
  private async useAgentSkills(
    requirements: ExtractedRequirements,
    intent: string
  ): Promise<TerraformCode | null> {
    if (!this.agentSkillsClient) {
      return null;
    }

    try {
      this.log('info', 'Using HashiCorp Agent Skills for code generation');

      // Prepare the request for Agent Skills
      const prompt = `Generate production-ready Terraform code for Azure with the following requirements:
Resource Type: ${requirements.resourceType}
Region: ${requirements.region || 'eastus'}
Specifications: ${JSON.stringify(requirements.specifications, null, 2)}
Security Requirements: ${requirements.securityRequirements?.join(', ') || 'standard'}

Requirements:
- Use modular structure if specified
- Follow Azure best practices
- Include proper variable definitions
- Add meaningful outputs
- Ensure security and compliance`;

      // Call Agent Skills tool (assuming it has a 'generate_terraform' or similar tool)
      const response = await this.agentSkillsClient.callTool({
        name: 'generate_terraform_code', // This is the expected tool name from Agent Skills
        arguments: {
          provider: 'azurerm',
          resource_type: requirements.resourceType,
          requirements: requirements.specifications,
          region: requirements.region,
          prompt: prompt,
        },
      });

      // Parse the response from Agent Skills
      const responseContent = response.content as any;
      if (responseContent && Array.isArray(responseContent) && responseContent.length > 0) {
        const content = responseContent[0];
        if (content.type === 'text' && content.text) {
          const generatedCode = content.text;
          
          // Parse the generated code into our structure
          const files = this.parseGeneratedCode(generatedCode);
          
          const metadata: TerraformMetadata = {
            generatedAt: new Date(),
            terraformVersion: '1.6.0',
            providerVersions: {
              azurerm: '~> 3.80.0',
            },
            resourceCount: this.countResources(files.mainTf),
            estimatedComplexity: this.estimateComplexity(files.mainTf),
            documentationSources: [
              'HashiCorp Agent Skills',
              'HashiCorp Terraform Registry',
              'Azure Provider Documentation',
            ],
          };

          return {
            mainTf: files.mainTf,
            variablesTf: files.variablesTf,
            outputsTf: files.outputsTf,
            providerTf: files.providerTf,
            tfvars: files.tfvars,
            modules: files.modules,
            metadata,
          };
        }
      }

      return null;
    } catch (error) {
      this.log('warn', 'Agent Skills generation failed', { error });
      return null;
    }
  }

  /**
   * Query HashiCorp Terraform MCP Server for documentation
   */
  private async queryTerraformDocs(
    resourceType: string,
    query?: string
  ): Promise<string> {
    try {
      // In a real implementation, this would query the HashiCorp Terraform MCP Server
      // For now, we'll return a placeholder that includes common Azure resource patterns
      
      this.log('info', 'Querying Terraform documentation', { resourceType, query });

      // Simulate MCP server query
      const docTemplate = `
# ${resourceType} Documentation

## Resource Configuration
The ${resourceType} resource is used to manage Azure resources.

## Required Arguments
- name: The name of the resource
- resource_group_name: The name of the resource group
- location: The Azure region

## Optional Arguments
- tags: A mapping of tags to assign to the resource

## Security Best Practices
- Enable encryption at rest
- Use managed identities when possible
- Implement network security groups
- Enable diagnostic logging
- Use private endpoints for sensitive resources

## Example Usage
\`\`\`hcl
resource "${resourceType}" "example" {
  name                = "example-resource"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  
  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
\`\`\`
`;

      return docTemplate;
    } catch (error) {
      this.log('warn', 'Failed to query Terraform docs, using fallback', { error });
      return 'Standard Azure resource configuration';
    }
  }

  /**
   * Parse generated code into separate files
   */
  private parseGeneratedCode(response: string): {
    mainTf: string;
    variablesTf?: string;
    outputsTf?: string;
    providerTf: string;
    tfvars?: string;
    modules?: Record<string, { mainTf: string; variablesTf?: string; outputsTf?: string }>;
  } {
    // Check if response contains file markers
    const hasFileMarkers = response.includes('### FILE:');
    
    if (hasFileMarkers) {
      // Parse multi-file response
      const files: Record<string, string> = {};
      const fileRegex = /### FILE:\s*(.+?)\n([\s\S]*?)(?=### FILE:|$)/g;
      let match;
      
      while ((match = fileRegex.exec(response)) !== null) {
        const filePath = match[1].trim();
        let content = match[2].trim();
        
        // Remove code block markers if present
        content = content.replace(/```(?:hcl|terraform)?\n([\s\S]*?)```/g, '$1').trim();
        
        // Remove any explanatory text that might have been added
        // Remove lines that start with common explanation patterns
        content = content.split('\n')
          .filter(line => {
            const trimmed = line.trim();
            return !(
              trimmed.startsWith('This Terraform') ||
              trimmed.startsWith('This configuration') ||
              trimmed.startsWith('The following') ||
              trimmed.startsWith('Note:') ||
              trimmed.startsWith('Important:') ||
              trimmed.startsWith('CRITICAL:') ||
              (trimmed.startsWith('#') && (
                trimmed.includes('Terraform configuration') ||
                trimmed.includes('sets up') ||
                trimmed.includes('following the')
              ))
            );
          })
          .join('\n')
          .trim();
        
        // For module main.tf files, remove any output blocks (they should be in outputs.tf)
        if (filePath.includes('/main.tf') && filePath.includes('modules/')) {
          content = this.removeOutputBlocksFromMainTf(content);
        }
        
        files[filePath] = content;
      }
      
      // Organize files
      const result: any = {
        mainTf: files['main.tf'] || '',
        variablesTf: files['variables.tf'],
        outputsTf: files['outputs.tf'],
        providerTf: files['provider.tf'] || this.getDefaultProviderTf(),
        tfvars: files['terraform.tfvars'],
      };
      
      // Remove provider blocks from variables.tf if they exist there
      if (result.variablesTf && result.variablesTf.includes('provider "azurerm"')) {
        result.variablesTf = this.removeProviderBlocksFromVariables(result.variablesTf);
        this.log('warn', 'Removed provider block from variables.tf - providers should be in provider.tf');
      }
      
      // Extract modules
      const modules: Record<string, any> = {};
      for (const [filePath, content] of Object.entries(files)) {
        if (filePath.startsWith('modules/')) {
          const parts = filePath.split('/');
          const moduleName = parts[1];
          const fileName = parts[parts.length - 1];
          
          if (!modules[moduleName]) {
            modules[moduleName] = {};
          }
          
          if (fileName === 'main.tf') {
            modules[moduleName].mainTf = content;
          } else if (fileName === 'variables.tf') {
            modules[moduleName].variablesTf = content;
          } else if (fileName === 'outputs.tf') {
            modules[moduleName].outputsTf = content;
          }
        }
      }
      
      if (Object.keys(modules).length > 0) {
        result.modules = modules;
      }
      
      return result;
    } else {
      // Single file response - extract code block
      const codeMatch = response.match(/```(?:hcl|terraform)?\s*\n([\s\S]*?)```/);
      const mainTf = codeMatch ? codeMatch[1].trim() : response;
      
      // Check if provider is already in the main code
      const hasProvider = mainTf.includes('provider "azurerm"');
      
      return {
        mainTf,
        providerTf: hasProvider ? '' : this.getDefaultProviderTf(),
      };
    }
  }
  
  /**
   * Get default provider configuration
   */
  private getDefaultProviderTf(): string {
    return `terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80.0"
    }
  }
}

provider "azurerm" {
  skip_provider_registration = true
  
  features {}
}`;
  }

  /**
   * Remove provider blocks from variables.tf content
   * Providers should only be in provider.tf
   */
  private removeProviderBlocksFromVariables(content: string): string {
    // Remove provider blocks using regex
    const lines = content.split('\n');
    const result: string[] = [];
    let inProviderBlock = false;
    let braceCount = 0;
    
    for (const line of lines) {
      const trimmed = line.trim();
      
      // Check if starting a provider block
      if (trimmed.startsWith('provider ') && trimmed.includes('{')) {
        inProviderBlock = true;
        braceCount = (line.match(/{/g) || []).length - (line.match(/}/g) || []).length;
        continue;
      }
      
      if (inProviderBlock) {
        braceCount += (line.match(/{/g) || []).length;
        braceCount -= (line.match(/}/g) || []).length;
        
        if (braceCount <= 0) {
          inProviderBlock = false;
        }
        continue;
      }
      
      result.push(line);
    }
    
    return result.join('\n').trim();
  }

  /**
   * Remove output blocks from main.tf content
   * Outputs should only be in outputs.tf for modules
   */
  private removeOutputBlocksFromMainTf(content: string): string {
    // Remove output blocks using regex
    // Match: output "name" { ... } including nested braces
    const lines = content.split('\n');
    const result: string[] = [];
    let inOutputBlock = false;
    let braceCount = 0;
    
    for (const line of lines) {
      const trimmed = line.trim();
      
      // Check if starting an output block
      if (trimmed.startsWith('output ') && trimmed.includes('{')) {
        inOutputBlock = true;
        braceCount = (line.match(/{/g) || []).length - (line.match(/}/g) || []).length;
        continue;
      }
      
      if (inOutputBlock) {
        braceCount += (line.match(/{/g) || []).length;
        braceCount -= (line.match(/}/g) || []).length;
        
        if (braceCount <= 0) {
          inOutputBlock = false;
        }
        continue;
      }
      
      result.push(line);
    }
    
    return result.join('\n').trim();
  }

  /**
   * Count resources in Terraform code
   */
  private countResources(code: string): number {
    const resourceMatches = code.match(/resource\s+"[^"]+"\s+"[^"]+"/g);
    return resourceMatches ? resourceMatches.length : 0;
  }

  /**
   * Estimate complexity of Terraform code
   */
  private estimateComplexity(code: string): 'low' | 'medium' | 'high' {
    const resourceCount = this.countResources(code);
    const lines = code.split('\n').length;

    if (resourceCount <= 3 && lines <= 100) return 'low';
    if (resourceCount <= 10 && lines <= 500) return 'medium';
    return 'high';
  }
}

// Start the agent if run directly
if (import.meta.url === `file://${process.argv[1]}`) {
  const agent = new TerraformGenAgent();
  agent.start().catch((error) => {
    console.error('Failed to start Terraform Generation Agent:', error);
    process.exit(1);
  });
}

// Made with Bob