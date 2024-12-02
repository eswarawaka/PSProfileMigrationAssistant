
## PSProfileMigrationAssistant

### Overview

`PSProfileMigrationAssistant` is a PowerShell module designed to streamline the migration of user profiles from one domain to another, especially in scenarios where users' SID history has been migrated. The tool ensures a seamless transition by automating the migration of profile data, minimizing manual effort, and providing flexibility through a GUI-based interface.

---

### Features

- **Domain Profile Migration**: Supports migration of user profiles from one domain to another after SID history migration.
- **Dynamic Profile Options**: Allows users to migrate full profiles or select specific data (e.g., Desktop, Documents, Downloads).
- **Environment Selection**: Enables Test and Production environment selection for flexibility during migration.
- **Progress Monitoring**: Provides a progress bar to track the migration process in real-time.
- **Configuration-Based**: Fully configurable via an external `Config.ini` file for ease of customization.
- **Error Feedback**: Displays errors and logs issues encountered during the migration.

---

### Prerequisites

1. **PowerShell Version**: Requires PowerShell 5.1 or later.
2. **Windows OS**: Compatible with Windows 10 and Windows 11.
3. **SID History Migration**:
   - Ensure that SID history has been migrated between the source and target domains.
4. **Dependencies**:
   - `System.Windows.Forms`
   - `System.Drawing`

---

### Installation

#### From PowerShell Gallery (Recommended)

1. Open PowerShell as Administrator.
2. Install the module:
   ```powershell
   Install-Module -Name PSProfileMigrationAssistant
   ```
3. Import the module:
   ```powershell
   Import-Module PSProfileMigrationAssistant
   ```

#### From Source

1. Clone or download the repository:
   ```bash
   git clone https://github.com/YourUsername/PSProfileMigrationAssistant.git
   ```
2. Navigate to the module directory:
   ```bash
   cd PSProfileMigrationAssistant
   ```
3. Import the module:
   ```powershell
   Import-Module .\PSProfileMigrationAssistant.psd1
   ```

---

### Configuration

The module uses a `Config.ini` file to define parameters for domain and file server details. Update the file located in `Public\Config\Config.ini` to match your environment.

#### Sample Config.ini
```ini
[Variables]
AppName=Profile Migration Assistant
PrimaryCatalog=MainCatalog

[Domain]
Domain1=old-domain.com
Domain2=new-domain.com

[FileShares]
FileserverTest=\\testserver\profiles
FileServerProd=\\prodserver\profiles

[RadioButtons]
Option1=Test
Option2=Prod

[Images]
ApplicationIcon=assets\icon.ico
BackgroundImage=assets\background.png
NextButtonImage=assets\next.png
TickMarkImage=assets\tick.png
CloseButtonImage=assets\close.png
```

---

### Usage

1. **Run the Assistant**:
   Launch the GUI by calling:
   ```powershell
   Show-MigrationForm
   ```

2. **Enter Email Address**:
   - Enter the email address of the user being migrated.
   - Ensure that the email address corresponds to the user in the old domain.

3. **Select Environment**:
   - Choose between `Test` and `Prod` environments using the radio buttons.

4. **Select Profile Migration Options**:
   - Opt to migrate the **full profile** or select specific folders like `Desktop`, `Documents`, or `Downloads`.

5. **Start Migration**:
   - Click the "Migrate Now" button.
   - Monitor progress via the progress bar.
   - A confirmation message will appear upon completion.


---

### Example Workflow

1. **User Setup**:
   - Ensure the user's account has been migrated to the new domain with the SID history correctly configured.

2. **Run the Tool**:
   - Use the `PSProfileMigrationAssistant` to migrate the user's profile data seamlessly to the new domain's server.

3. **Verify Migration**:
   - Check that all selected profile data has been successfully moved to the new domain.

---

### Issues

If you encounter any issues or have suggestions, please report them in the [GitHub Issues](https://github.com/eswarawaka/PSProfileMigrationAssistant/issues) section.

---

### License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
