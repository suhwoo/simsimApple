# Flutter Environment Setup Guide for macOS (Apple Silicon)

This guide outlines the steps to set up a Flutter development environment on a macOS machine with Apple Silicon (M1, M2, M3, M4 series).

**User Environment Summary (as of this guide's last update):**
*   **Machine:** Mac with Apple Silicon (M4 Pro)
*   **macOS Version:** Sonoma 15.4.1 (or later, as per `flutter doctor` output)
*   **Shell:** `zsh`
*   **Flutter SDK Location:** `~/development/flutter`
*   **Xcode Version:** 16.3
*   **Android Studio Version:** 2024.3 (Apple Silicon version)
*   **CocoaPods:** Installed via Homebrew

## Prerequisites

*   **macOS:** Version 11 (Big Sur) or later.
*   **Shell:** `zsh` (default on recent macOS versions).
*   **Homebrew:** While not strictly required for Flutter itself, it was used in this setup to install CocoaPods. Installation instructions: [https://brew.sh/](https://brew.sh/)

## Installation Steps

1.  **Install Rosetta 2 (If prompted or for broader compatibility):**
    *   Rosetta 2 enables a Mac with Apple silicon to use apps built for a Mac with an Intel processor.
    *   Open your terminal and run:
        ```bash
        sudo softwareupdate --install-rosetta --agree-to-license
        ```
    *   You will be prompted to enter your macOS user password.

2.  **Install Xcode:**
    *   Xcode is Apple's integrated development environment (IDE) for macOS. It includes tools and SDKs for iOS and macOS development.
    *   **Installation:**
        1.  Open the **App Store** on your Mac.
        2.  Search for "Xcode" and install it (e.g., version 16.3).
    *   **Post-installation configuration:**
        1.  Open Xcode once to complete component installation.
        2.  In the terminal, run:
            ```bash
            sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
            sudo xcodebuild -runFirstLaunch
            sudo xcodebuild -license 
            ```
            (Agree to the license when prompted).

3.  **Install the Flutter SDK using VS Code / Cursor IDE:**
    1.  **Install the Flutter Extension:**
        *   Launch Cursor (or VS Code).
        *   Open Extensions (Cmd+Shift+X).
        *   Search for "Flutter" and install the official extension by Dart Code.
    2.  **Install Flutter SDK via Extension:**
        *   Open Command Palette (Cmd+Shift+P).
        *   Type `flutter` and select **Flutter: New Project**.
        *   When prompted to locate the Flutter SDK, select **Download SDK**.
        *   Choose a temporary location (e.g., within your project folder on the Desktop like `~/Desktop/flutter/flutter`).
        *   Click **Clone Flutter**.
    3.  **Move Flutter SDK to a Standard Location (Recommended):**
        *   Create a dedicated directory for development tools if you don't have one:
            ```bash
            mkdir -p ~/development
            ```
        *   Move the cloned Flutter SDK:
            ```bash
            mv YOUR_TEMPORARY_FLUTTER_SDK_PATH/flutter ~/development/flutter
            ```
            (e.g., `mv ~/Desktop/flutter/flutter ~/development/`)
    4.  **Add Flutter to your PATH:**
        *   Open your `~/.zshrc` file (since you're using `zsh`):
            ```bash
            open -e ~/.zshrc
            ```
        *   Add the following line, ensuring it's placed correctly (e.g., after any Homebrew `shellenv` lines but before other scripts that might modify PATH or source other files):
            ```zsh
            export PATH="$HOME/development/flutter/bin:$PATH"
            ```
        *   Save the file.
        *   **Crucial:** Open a **brand new terminal window** for the changes to take effect. Verify by typing `which flutter` (should show `~/development/flutter/bin/flutter`) and `flutter --version`.

4.  **Install CocoaPods (using Homebrew):**
    *   CocoaPods is a dependency manager for iOS/macOS projects.
    *   If you don't have Homebrew, install it from [https://brew.sh/](https://brew.sh/).
    *   In the terminal, run:
        ```bash
        brew install cocoapods
        ```

5.  **Install Android Studio:**
    1.  Download Android Studio for **Mac (Apple Silicon)** from [https://developer.android.com/studio](https://developer.android.com/studio) (e.g., version 2024.3).
    2.  Install it by dragging the application to your `Applications` folder.
    3.  Launch Android Studio and complete the Setup Wizard. This will install the latest Android SDK, command-line tools, and build tools.
    4.  (Optional but recommended for M-series Macs) If you plan to use Android Emulators, ensure you create AVDs (Android Virtual Devices) using **ARM64 (arm64-v8a)** system images for best performance.

6.  **Run `flutter doctor` and Resolve Issues:**
    *   Open a **new** terminal window.
    *   Run `flutter doctor`. This command checks your environment and reports the status.
    *   **Address any reported issues:**
        *   **Android Licenses:** If prompted by `flutter doctor` (`✗ Android toolchain - develop for Android devices (Android SDK version ...) ... ✗ Android license status unknown.`), run:
            ```bash
            flutter doctor --android-licenses
            ```
            And accept all licenses by typing 'y'.
        *   **Chrome for Web Development:** If `flutter doctor` indicates Chrome is missing (`! Chrome - develop for the web (Cannot find Chrome executable)`), download and install Google Chrome from [https://www.google.com/chrome/](https://www.google.com/chrome/).
        *   **Other issues:** Follow the guidance from `flutter doctor`.

7.  **Final Check:**
    *   Run `flutter doctor` one last time in a new terminal.
    *   You should see all green checkmarks `[✓]` for Flutter, Android toolchain, Xcode, Chrome, and Android Studio, with a final message "• No issues found!".

## Create Your First Flutter Application

Once `flutter doctor` reports no issues:

1.  Navigate to the directory where you want to create your project (e.g., `~/Desktop` or a dedicated projects folder).
    ```bash
    cd path/to/your/projects_folder
    ```
2.  Run the create command:
    ```bash
    flutter create hello_world
    ```
3.  Navigate into the project directory:
    ```bash
    cd hello_world
    ```
4.  Run the app:
    ```bash
    flutter run
    ```
    Flutter will ask which device you want to run on if multiple are available (e.g., an iOS Simulator, an Android Emulator, or Chrome for web).

This comprehensive guide should help others (and your future self!) replicate your setup. 