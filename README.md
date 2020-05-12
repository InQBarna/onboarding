# Onboarding

Package that displays a customizable Onboarding with various default and custom steps. 
Uses WhatsNewKit package to handle the version checking and to display the default UI for each onboarding step.

---
## Default steps 

##### Blocking screen
Displays a blocking screen with a message to update and a link to the AppStore.
- Minimum version is passed as a "X.Y.Z" string
- a URL String is passed to navigate to the AppStore app page with a button tap 
e.g. ``` .blocking(minVersion: "8.1.0", appStoreUrlString: "itms-apps://itunes.apple.com/es/app/id364587804") ```

##### What's new
Displays just once when a WhatsNew file is provided.
    - Provide a "WhatsNewCleanInstall.json" file to display with a fresh install
    - Provide a "WhatsaNewX.Y.Z.json" file for a X.Y.Z version to display when updating and when not in a fresh install. 
            **Have to match X.Y.Z in the "version" attribute inside the json file**

---
## Custom steps

Display a custom UIViewController as an onboardings step. The custom ViewController should be responsible for handling user actions. After the user finishes the necessary interaction or some time limit is passed the custom VC should call Onboarding's instance method:
```moveToNextStep()```

You can create and pass an OnboardingViewController with a WhatsNew struct to preserve the UI consistency with the default presented ViewControllers. OnboardingSceneBuilder provides a defaultCustomizedConfiguration function that configures elements accordingly.  
