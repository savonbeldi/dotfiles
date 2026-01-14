# Azure Identity 101

## Overview

Understanding the relationship between **App Registrations**, **Service Principals**, and **Enterprise Applications** is crucial for working with Azure identity and access management. These three concepts are closely interconnected but serve different purposes.

## The Three Core Concepts

### 1. App Registration (Application Object)

**Purpose:**

- The global, unique definition of your application across all Azure AD tenants
- Acts as the "blueprint" or "template" for your application
- Defines how your application can authenticate and what permissions it needs

**Key Characteristics:**

- Lives in the **home tenant** where it was created
- Contains the application's identity configuration
- Defines authentication settings, redirect URIs, certificates, secrets, and API permissions
- There is **only one App Registration** per application, regardless of how many tenants use it

**What it stores:**

- Application ID (Client ID)
- Authentication settings (certificates, secrets)
- **API permissions**: What Microsoft/custom APIs your app wants to call (requested, but not granted here)
- Redirect URIs
- **App roles**: Custom roles you define for your application (defined here, assigned elsewhere)
- Branding information
- Token configuration

**Use Cases:**

- When you need to register a new application that will authenticate with Azure AD
- When you need to configure OAuth 2.0 or OpenID Connect settings
- When you need to define what API permissions your app requires
- When you need to create custom roles (App Roles) for application authorization

---

### 2. Service Principal

**Purpose:**

- The **local representation** of an application in a specific tenant
- Acts as the identity of the application when it needs to access resources
- The actual security principal that gets assigned permissions and roles

**Key Characteristics:**

- Created automatically when you consent to use an app in your tenant
- There can be **multiple Service Principals** (one per tenant) for a single App Registration
- This is what Azure RBAC roles are assigned to
- This is what actually authenticates and accesses resources

**Types of Service Principals:**

1. **Application**: Linked to an App Registration
2. **Managed Identity**: Azure-managed identities for Azure resources
3. **Legacy**: Older applications created before App Registrations existed

**What it contains:**

- Reference to the App Registration (Application ID)
- Tenant-specific configurations
- **Azure RBAC role assignments**: What Azure resources this identity can access
- **API permission grants**: Which API permissions have been consented/granted in this tenant
- Policies and Conditional Access rules
- OAuth2 permission grants (consent records)

**Use Cases:**

- When an application needs to access Azure resources (assign RBAC roles here)
- When you need to assign Azure RBAC roles to an application
- For automation scripts and CI/CD pipelines
- For managed identities on Azure VMs, App Services, etc.
- When granting consent for API permissions

---

### 3. Enterprise Application

**Purpose:**

- The **UI representation** of a Service Principal in the Azure Portal
- Provides management interface for the application instance in your tenant
- Used for user assignment, SSO configuration, and access management

**Key Characteristics:**

- Essentially the Azure Portal's view of a Service Principal
- Shows up in "Enterprise Applications" blade in Azure Portal
- Used for managing user access, SSO, and provisioning
- Where you configure user assignment and Conditional Access policies

**What you can manage here:**

- **Users and groups assigned to the application**: Assign users/groups to App Roles
- **Single Sign-On (SSO) settings**
- **API permission consent**: Grant admin consent for API permissions
- Provisioning configurations
- Conditional Access policies
- Activity logs and sign-ins
- Application proxy settings

**Use Cases:**

- When you need to assign users/groups to an application (and to specific App Roles)
- When you need to configure SSO for SaaS applications
- When you need to monitor application usage and sign-ins
- When you need to set up automatic user provisioning
- When you need to grant admin consent for API permissions

---

## Permissions and Roles: Understanding the Differences

One of the most confusing aspects of Azure identity is understanding the different types of permissions and roles. There are three main categories, each serving different purposes and assigned to different objects.

### 1. Azure RBAC Roles

**What they are:**
- Roles that control access to **Azure resources** (subscriptions, resource groups, VMs, storage accounts, etc.)
- Examples: Owner, Contributor, Reader, Virtual Machine Contributor, Storage Blob Data Reader

**Where they're configured:**
- Azure Portal → Resource → Access Control (IAM)
- Or any Azure resource's IAM blade

**What object they're assigned TO:**
- **Service Principals** (the identity that needs access)
- Also can be assigned to users, groups, or managed identities

**Where the assignment lives:**
- On the Azure resource itself (subscription, resource group, or specific resource)
- Part of Azure Resource Manager (ARM), not Azure AD

**Use case example:**
```bash
# Give a Service Principal permission to manage VMs in a resource group
az role assignment create \
  --assignee <service-principal-object-id> \
  --role "Virtual Machine Contributor" \
  --scope "/subscriptions/<sub-id>/resourceGroups/<rg-name>"
```

**Key point:** RBAC roles control what the Service Principal can do with **Azure infrastructure**.

---

### 2. API Permissions (Delegated & Application Permissions)

**What they are:**
- Permissions to call **Microsoft APIs** (Microsoft Graph, Azure AD Graph, custom APIs)
- Allow your application to read/write data in Microsoft 365, Azure AD, etc.
- Two types:
  - **Delegated permissions**: Act on behalf of a signed-in user
  - **Application permissions**: Act as the application itself (no user context)

**Where they're configured:**
- Azure Portal → App Registrations → Your App → API Permissions
- This is where you REQUEST the permissions

**What object they're configured ON:**
- **App Registration** (the application definition)
- These are part of the app's manifest

**Where consent/grant happens:**
- Can be granted by:
  - Individual users (user consent)
  - Tenant administrators (admin consent via Enterprise Application or App Registration)
- The consent is stored on the **Service Principal** in that tenant

**Common API permissions examples:**
```
Microsoft Graph API:
- User.Read (delegated): Read the signed-in user's profile
- User.Read.All (application): Read all users' profiles
- Mail.Send (delegated): Send mail as the signed-in user
- Mail.Send (application): Send mail as the application
- Directory.Read.All (application): Read all directory data
```

**Use case example:**
```bash
# Add Microsoft Graph User.Read.All permission to an app
az ad app permission add \
  --id <app-id> \
  --api 00000003-0000-0000-c000-000000000000 \
  --api-permissions e1fe6dd8-ba31-4d61-89e7-88639da4683d=Role

# Grant admin consent
az ad app permission admin-consent --id <app-id>
```

**Key point:** API permissions control what the application can do with **Microsoft APIs and data**, not Azure infrastructure.

---

### 3. App Roles (Custom Application Roles)

**What they are:**
- Custom roles that **you define** for your own application
- Used to implement role-based access control (RBAC) within your application
- Examples: "Admin", "Reader", "Approver", "HR.Manager"

**Where they're defined:**
- Azure Portal → App Registrations → Your App → App Roles
- Defined in the App Registration manifest

**What object they're defined ON:**
- **App Registration** (the application definition)

**Where they're assigned:**
- Azure Portal → Enterprise Applications → Your App → Users and Groups
- You assign users/groups to specific App Roles

**What object they're assigned TO:**
- **Users** or **Groups** (people who will use the application)
- Can also be assigned to other Service Principals (application-to-application scenarios)

**Where the assignment lives:**
- On the **Service Principal** (Enterprise Application) in that tenant
- Retrieved via claims in the authentication token

**Use case example:**
```bash
# Define app roles in the app manifest (typically done via portal or manifest file)
# Then assign a user to an app role
az ad app role assignment add \
  --id <enterprise-app-object-id> \
  --assignee <user-object-id> \
  --role <app-role-id>
```

**How your app uses them:**
- When a user signs in, the token contains a `roles` claim
- Your application code checks this claim to determine what the user can do
- Example token claim: `"roles": ["Admin", "Approver"]`

**Key point:** App Roles control what users can do **within your application**, based on your custom logic.

---

### Visual Summary: Where Everything is Configured

```
┌─────────────────────────────────────────────────────────────────┐
│                      APP REGISTRATION                           │
│                   (Application Definition)                      │
│                                                                 │
│  ┌────────────────────────────────────────────────────────┐    │
│  │ API PERMISSIONS (requested)                            │    │
│  │ - Microsoft Graph: User.Read.All                       │    │
│  │ - Microsoft Graph: Mail.Send                           │    │
│  │ - Custom API: Read.Data                                │    │
│  │                                                        │    │
│  │ WHERE: App Registration → API Permissions              │    │
│  │ ASSIGNED TO: App Registration (requested)              │    │
│  └────────────────────────────────────────────────────────┘    │
│                                                                 │
│  ┌────────────────────────────────────────────────────────┐    │
│  │ APP ROLES (defined)                                    │    │
│  │ - "Admin": Can manage all data                         │    │
│  │ - "Reader": Can only read data                         │    │
│  │ - "Approver": Can approve requests                     │    │
│  │                                                        │    │
│  │ WHERE: App Registration → App Roles                    │    │
│  │ DEFINED IN: App Registration                           │    │
│  └────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ Creates
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                   SERVICE PRINCIPAL                             │
│                  (Tenant-Local Identity)                        │
│                                                                 │
│  ┌────────────────────────────────────────────────────────┐    │
│  │ AZURE RBAC ROLES (assigned)                            │    │
│  │ - Contributor on Resource Group "Production"           │    │
│  │ - Storage Blob Data Reader on Storage Account          │    │
│  │ - Key Vault Secrets User on Key Vault                  │    │
│  │                                                        │    │
│  │ WHERE: Azure Resources → IAM                           │    │
│  │ ASSIGNED TO: Service Principal                         │    │
│  └────────────────────────────────────────────────────────┘    │
│                                                                 │
│  ┌────────────────────────────────────────────────────────┐    │
│  │ API PERMISSIONS (granted/consented)                    │    │
│  │ - Microsoft Graph: User.Read.All ✓ (admin consent)     │    │
│  │ - Microsoft Graph: Mail.Send ✓ (admin consent)         │    │
│  │                                                        │    │
│  │ WHERE: Consent recorded on Service Principal           │    │
│  │ GRANTED TO: Service Principal                          │    │
│  └────────────────────────────────────────────────────────┘    │
│                                                                 │
│  ┌────────────────────────────────────────────────────────┐    │
│  │ APP ROLE ASSIGNMENTS (to users/groups)                 │    │
│  │ - Alice → "Admin" role                                 │    │
│  │ - Bob → "Reader" role                                  │    │
│  │ - HR Group → "Approver" role                           │    │
│  │                                                        │    │
│  │ WHERE: Enterprise Application → Users and Groups       │    │
│  │ ASSIGNED TO: Users/Groups/Service Principals           │    │
│  └────────────────────────────────────────────────────────┘    │
│                                                                 │
│  Visible in Portal as: ENTERPRISE APPLICATION                  │
└─────────────────────────────────────────────────────────────────┘
```

---

### Detailed Comparison Table

| Aspect | Azure RBAC Roles | API Permissions | App Roles |
|--------|------------------|-----------------|------------|
| **Purpose** | Access to Azure resources | Access to Microsoft/custom APIs | Access within your app |
| **Examples** | Contributor, Reader, Owner | User.Read, Mail.Send | Admin, Approver, Viewer |
| **Defined where** | Built-in (Azure) | Built-in (API) or custom | Custom (your app) |
| **Configured in** | Azure Resource IAM | App Registration → API Permissions | App Registration → App Roles |
| **Assigned to** | Service Principal, User, Group | App Registration (requested), Service Principal (granted) | Users, Groups, Service Principals |
| **Assignment location** | On the Azure resource | Enterprise App (consent) | Enterprise App → Users and Groups |
| **Scope** | Azure resources (infra) | API operations (data) | Application features |
| **Who assigns** | Azure resource owner | Admin (admin consent) or User (user consent) | Application owner |
| **Used for** | Managing Azure infrastructure | Calling Microsoft Graph, etc. | Custom app authorization |
| **In token as** | N/A (checked by Azure ARM) | `scp` (delegated) or `roles` (application) | `roles` claim |
| **Check done by** | Azure Resource Manager | Microsoft API endpoints | Your application code |

---

### Practical Scenarios

#### Scenario 1: Automation Script Reading Key Vault

**Need:** Script needs to read secrets from Azure Key Vault

**Solution:**
1. Create App Registration → Service Principal is auto-created
2. Assign **Azure RBAC Role**: "Key Vault Secrets User" to the Service Principal on the Key Vault
3. Script authenticates with Client ID + Secret
4. Azure Resource Manager checks RBAC, allows access

**Note:** No API permissions needed (this is Azure resource access, not API access)

---

#### Scenario 2: Application Reading User Profiles

**Need:** Web app needs to read user profiles from Azure AD

**Solution:**
1. Create App Registration
2. Add **API Permission**: Microsoft Graph → User.Read.All (delegated or application)
3. Admin grants consent (recorded on Service Principal)
4. Application calls Microsoft Graph API
5. Microsoft Graph checks the granted permissions, allows access

**Note:** No Azure RBAC needed (this is API access, not Azure resource access)

---

#### Scenario 3: Multi-Tenant SaaS with Different User Roles

**Need:** SaaS app with different user access levels (Admin, User, Viewer)

**Solution:**
1. Create App Registration
2. Define **App Roles**: "Admin", "User", "Viewer" in App Registration
3. Each customer tenant admin assigns their users to roles via Enterprise Application
4. When users sign in, token contains roles claim: `["Admin"]`
5. Your app code checks roles claim to determine what UI/features to show

**Note:** No Azure RBAC needed (users aren't accessing Azure resources). API permissions may be needed if the app calls Microsoft Graph.

---

#### Scenario 4: Comprehensive Enterprise Application

**Need:** Enterprise app that:
- Deploys infrastructure to Azure
- Reads user data from Azure AD
- Has different roles for end users

**Solution:**
1. Create App Registration
2. **Azure RBAC Role**: Assign "Contributor" to Service Principal on subscription (for deploying infrastructure)
3. **API Permission**: Add Microsoft Graph → User.Read.All (for reading user data)
4. **App Roles**: Define "Admin", "Manager", "Employee" (for application authorization)
5. Grant admin consent for API permissions
6. Assign users to App Roles via Enterprise Application

**All three types used together!**

---

### Common Mistakes and Confusion

#### ❌ Mistake 1: Confusing Azure RBAC with API Permissions

**Wrong thinking:** "I need to read user profiles from Azure AD, so I'll assign the 'Reader' RBAC role"

**Why it's wrong:** Azure RBAC roles control Azure resources, not API access.

**Correct approach:** Add Microsoft Graph API permission "User.Read.All"

---

#### ❌ Mistake 2: Confusing App Roles with Azure RBAC Roles

**Wrong thinking:** "I created an app role called 'Contributor', so my app can now manage Azure resources"

**Why it's wrong:** App Roles are custom roles for your app's logic, not Azure resource access.

**Correct approach:** Assign Azure RBAC "Contributor" role to the Service Principal

---

#### ❌ Mistake 3: Assigning API Permissions to Users

**Wrong thinking:** "This user needs to read emails, so I'll assign Mail.Read permission to them"

**Why it's wrong:** API permissions are assigned to applications (App Registrations), not users.

**Correct approach:** 
- Add Mail.Read permission to the App Registration
- The user authorizes (consents) the app to access their mail
- Or define an App Role in your app for "Mail Reader" and assign users to it

---

#### ❌ Mistake 4: Trying to Assign RBAC Roles to App Registration

**Wrong thinking:** "I'll assign the Contributor role to my App Registration"

**Why it's wrong:** RBAC roles are assigned to Service Principals, not App Registrations.

**Correct approach:** Assign the role to the Service Principal (which was created from the App Registration)

---

## The Relationship: How They Work Together

```
┌─────────────────────────────────────────────────────────────┐
│                    TENANT A (Home Tenant)                   │
│                                                             │
│  ┌─────────────────────────┐       ┌──────────────────────┐ │
│  │   App Registration      │       │  Service Principal   │ │
│  │   (Application Object)  │───────│  (Local Instance)    │ │
│  │                         │       │                      │ │
│  │  - Global Definition    │       │  - Local Identity    │ │
│  │  - Client ID            │       │  - RBAC Assignments  │ │
│  │  - Auth Settings        │       │                      │ │
│  │  - API Permissions      │       │  Visible as:         │ │
│  └─────────────────────────┘       │  Enterprise App      │ │
│                                    └──────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                    │
                    │ App can be used in other tenants
                    │
┌───────────────────▼─────────────────────────────────────────┐
│                      TENANT B                               │
│                                                             │
│              ┌──────────────────────┐                       │
│              │  Service Principal   │                       │
│              │  (Local Instance)    │                       │
│              │                      │                       │
│              │  - References App    │                       │
│              │    from Tenant A     │                       │
│              │  - Local RBAC        │                       │
│              │                      │                       │
│              │  Visible as:         │                       │
│              │  Enterprise App      │                       │
│              └──────────────────────┘                       │
└─────────────────────────────────────────────────────────────┘
```

### The Creation Flow

**When you create an App Registration:**

1. An **App Registration** (Application Object) is created in your tenant
2. A **Service Principal** is automatically created in the same tenant
3. The **Service Principal** appears as an **Enterprise Application** in the portal

**When someone in another tenant uses your app:**

1. They consent to your application
2. A **Service Principal** is created in their tenant (referencing your App Registration)
3. They see an **Enterprise Application** in their portal (their local Service Principal)
4. Your original **App Registration** remains unchanged in your tenant

---

## Practical Examples

### Example 1: Multi-Tenant SaaS Application

You build a SaaS application called "MyApp":

- **Your Tenant (Tenant A)**:
  - You create an App Registration for "MyApp" → This is the source of truth
  - A Service Principal is auto-created in your tenant
- **Customer Tenant (Tenant B)**:
  - Customer admin grants consent to "MyApp"
  - A Service Principal for "MyApp" is created in their tenant
  - They can now assign their users to "MyApp" via Enterprise Applications
  - They can configure SSO and Conditional Access for "MyApp"

### Example 2: Automation Script with Service Principal

You need a script to manage Azure resources:

1. **Create App Registration**: Register an app called "DevOps-Automation"
2. **Service Principal Created**: Azure creates the Service Principal automatically
3. **Assign Permissions**: Give the Service Principal "Contributor" role on your subscription
4. **Authenticate**: Your script uses Client ID + Secret to authenticate
5. **Access Resources**: The Service Principal's identity is used to access Azure APIs

### Example 3: Managed Identity (Special Case)

For Azure VMs or App Services:

- **No App Registration needed**: Azure manages this
- **Service Principal created automatically**: Managed Identity type
- **Shows as Enterprise Application**: You can see it in the portal
- **Direct role assignment**: Assign RBAC roles directly to the Managed Identity

---

## Key Differences Summary

| Aspect                            | App Registration                                  | Service Principal                          | Enterprise Application                        |
| --------------------------------- | ------------------------------------------------- | ------------------------------------------ | --------------------------------------------- |
| **Scope**                         | Global (one per app)                              | Per-tenant                                 | Per-tenant                                    |
| **Purpose**                       | Application definition                            | Security identity                          | UI/Management view                            |
| **Location**                      | Home tenant only                                  | Every tenant using the app                 | Portal view in each tenant                    |
| **What you configure**            | Auth methods, API permissions (request), App Roles (define) | Azure RBAC roles, API permissions (grant)  | User access, App Role assignments, SSO, consent |
| **Portal Blade**                  | App Registrations                                 | Not directly visible                       | Enterprise Applications                       |
| **Permissions/Roles stored**      | API permissions (requested), App Roles (defined)  | RBAC roles (assigned), API permissions (consented) | App Role assignments (users→roles)            |
| **Can be deleted independently?** | Deletes all Service Principals                    | Yes (local only)                           | Same as Service Principal                     |

---

## Common Questions

### Q: Do I always need both App Registration and Service Principal?

**A:** When you create an App Registration, a Service Principal is automatically created in the same tenant. However, you can have Service Principals without App Registrations (e.g., Managed Identities).

### Q: What happens if I delete the App Registration?

**A:** All Service Principals across all tenants that reference this App Registration will stop working.

### Q: What happens if I delete the Enterprise Application (Service Principal)?

**A:** Only that tenant's instance is deleted. The App Registration and Service Principals in other tenants are unaffected.

### Q: Can I have a Service Principal without an App Registration?

**A:** Yes, for Managed Identities and some legacy scenarios.

### Q: Where do I assign Azure RBAC roles?

**A:** To the Service Principal, via the Azure resource's IAM (Identity and Access Management) blade. Navigate to the resource → Access Control (IAM) → Add role assignment → Select the Service Principal.

### Q: Where do I configure authentication secrets?

**A:** In the App Registration (this is the source of truth for authentication).

### Q: Where do I assign users to an application?

**A:** In the Enterprise Application → Users and Groups (the portal view of the Service Principal).

### Q: Where do I request API permissions?

**A:** In the App Registration → API Permissions. This is where you specify what APIs your app wants to call.

### Q: Where do I grant/consent API permissions?

**A:** In the Enterprise Application → Permissions, or in the App Registration → API Permissions → Grant admin consent. The consent is recorded on the Service Principal.

### Q: Where do I define App Roles?

**A:** In the App Registration → App Roles. These are the custom roles for your application.

### Q: Where do I assign users to App Roles?

**A:** In the Enterprise Application → Users and Groups. Select a user/group and assign them to a specific role.

### Q: What's the difference between Azure RBAC roles and App Roles?

**A:** Azure RBAC roles control access to Azure infrastructure (VMs, storage, etc.), while App Roles are custom roles you define for your own application's authorization logic.

### Q: What's the difference between Azure RBAC roles and API permissions?

**A:** RBAC roles are for Azure resource management (infrastructure), while API permissions are for calling Microsoft/custom APIs (data and services).

---

## Best Practices

1. **Use Managed Identities when possible** - They eliminate the need to manage credentials
2. **Use separate App Registrations for different environments** - Dev, Test, Prod should have their own
3. **Regularly rotate secrets and certificates** - Set expiration dates and monitor them
4. **Apply least privilege** - Only grant the minimum permissions needed
5. **Use certificate-based authentication over secrets** when possible
6. **Monitor sign-in logs** - Use Enterprise Applications to track usage
7. **Enable Conditional Access** - Protect service principals with policies
8. **Document your Service Principals** - Keep track of what each one is used for

---

## Quick Reference Commands

### Azure CLI

```bash
# ============================================
# App Registration
# ============================================
# Create App Registration
az ad app create --display-name "MyApp"

# Create Service Principal from App Registration
az ad sp create --id <app-id>

# List all Service Principals
az ad sp list --all

# Create App Registration with Service Principal in one command
az ad sp create-for-rbac --name "MyApp" --role Contributor

# ============================================
# Azure RBAC Roles (assigned to Service Principal)
# ============================================
# Assign Azure RBAC role to Service Principal (subscription level)
az role assignment create \
  --assignee <service-principal-object-id> \
  --role "Contributor" \
  --scope "/subscriptions/<subscription-id>"

# Assign RBAC role to Service Principal (resource group level)
az role assignment create \
  --assignee <service-principal-object-id> \
  --role "Storage Blob Data Reader" \
  --scope "/subscriptions/<sub-id>/resourceGroups/<rg-name>"

# List role assignments for a Service Principal
az role assignment list --assignee <service-principal-object-id>

# ============================================
# API Permissions (configured on App Registration)
# ============================================
# Add Microsoft Graph API permission (User.Read.All - Application permission)
az ad app permission add \
  --id <app-id> \
  --api 00000003-0000-0000-c000-000000000000 \
  --api-permissions e1fe6dd8-ba31-4d61-89e7-88639da4683d=Role

# Add Microsoft Graph API permission (User.Read - Delegated permission)
az ad app permission add \
  --id <app-id> \
  --api 00000003-0000-0000-c000-000000000000 \
  --api-permissions e1fe6dd8-ba31-4d61-89e7-88639da4683d=Scope

# Grant admin consent for API permissions
az ad app permission admin-consent --id <app-id>

# List API permissions for an app
az ad app permission list --id <app-id>

# ============================================
# App Roles (defined in App Registration, assigned in Enterprise App)
# ============================================
# Define app roles (typically done via manifest or portal)
# Assign user to app role
az ad app role assignment add \
  --resource <enterprise-app-object-id> \
  --assignee <user-object-id> \
  --role <app-role-id>

# List app role assignments
az ad app role assignment list --id <enterprise-app-object-id>
```

### PowerShell

```powershell
# ============================================
# App Registration
# ============================================
# Create App Registration
New-AzADApplication -DisplayName "MyApp"

# Create Service Principal
New-AzADServicePrincipal -ApplicationId <app-id>

# Get all Service Principals
Get-AzADServicePrincipal

# ============================================
# Azure RBAC Roles (assigned to Service Principal)
# ============================================
# Assign Azure RBAC role to Service Principal
New-AzRoleAssignment `
  -ObjectId <service-principal-object-id> `
  -RoleDefinitionName "Contributor" `
  -Scope "/subscriptions/<subscription-id>"

# Assign RBAC role at resource group level
New-AzRoleAssignment `
  -ObjectId <service-principal-object-id> `
  -RoleDefinitionName "Storage Blob Data Reader" `
  -ResourceGroupName "MyResourceGroup"

# List role assignments
Get-AzRoleAssignment -ObjectId <service-principal-object-id>

# ============================================
# API Permissions (Microsoft Graph)
# ============================================
# Add Microsoft Graph permission (requires Microsoft Graph PowerShell SDK)
Import-Module Microsoft.Graph.Applications

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "Application.ReadWrite.All"

# Get Microsoft Graph Service Principal
$graphSP = Get-MgServicePrincipal -Filter "appId eq '00000003-0000-0000-c000-000000000000'"

# Add required resource access (API permissions)
Update-MgApplication -ApplicationId <app-id> -RequiredResourceAccess @(
    @{
        ResourceAppId = "00000003-0000-0000-c000-000000000000"
        ResourceAccess = @(
            @{
                Id = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"  # User.Read.All
                Type = "Role"  # Application permission
            }
        )
    }
)

# ============================================
# App Role Assignments
# ============================================
# Assign user to app role (requires Microsoft Graph PowerShell SDK)
New-MgServicePrincipalAppRoleAssignedTo `
  -ServicePrincipalId <enterprise-app-object-id> `
  -PrincipalId <user-object-id> `
  -ResourceId <enterprise-app-object-id> `
  -AppRoleId <app-role-id>

# List app role assignments
Get-MgServicePrincipalAppRoleAssignedTo -ServicePrincipalId <enterprise-app-object-id>
```

---

## Conclusion

Understanding these three concepts and their relationships is fundamental to working with Azure identity:

- **App Registration** = The application definition (blueprint)
- **Service Principal** = The security identity (instance)
- **Enterprise Application** = The management interface (portal view)

Think of it like a class in programming: App Registration is the class definition, and Service Principals are the instances of that class in different tenants.
