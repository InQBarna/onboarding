# Onboarding

Package that displays a customizable Onboarding with various default and custom steps. 

---
## Default steps 

##### blocking screen
Displays a blocking screen with a message to update and a link to the AppStore.
- Minimum version is passed as a "X.Y.Z" string
- a URL String is passed to navigate to the AppStore app page with a button tap 
e.g. ``` .blocking(minVersion: "8.1.0", appStoreUrlString: "itms-apps://itunes.apple.com/es/app/id364587804") ```

##### What's new
Displays just once when a WhatsNew file is provided.
    - Provide a "WhatsNewCleanInstall.json" file to display with a fresh install
    - Provide a "WhatsaNewX.Y.Z.json" file for a X.Y.Z version to display when updating and when not in a fresh install. **Have to match X.Y.Z in the "version" attribute inside the json file**
        
##### Push permissions

---
## Custom steps
 * default design
 * custom design
