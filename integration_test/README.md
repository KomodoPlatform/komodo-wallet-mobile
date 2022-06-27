# Integration Testing

## 1. General info

 - Integration testing is implemented using Flutter built-in [integration_test](https://github.com/flutter/flutter/tree/main/packages/integration_test) package.
 - New tests should be added, if possible, for every new issue as a part of corresponding PR, to provide coverage for specific bug/feature. This way we'll, hopefully, expand test coverage in a natural manner.
 - Coverage (and structure, if needed) should be updated in table below.

## 2. App structure and test coverage

 - **Main screen, Wallets manager**
   - [x] Create wallet
   - [x] Restore wallet
   - [x] Login to wallet
 - **Portfolio**
   - [ ] Main wallet page
     - [ ] Total fiat balance
     - [ ] Assets list item
       - [ ] Swipe left (disable)
       - [ ] Swipe right (send, receive, swap)
   - [ ] Add/activate assets page
     - [ ] Search field
     - [ ] 'Activate all' [protocol] checkbox
     - [ ] 'Done' button
   - [ ] Asset details page
     - [ ] Balance, fiat balance
     - [ ] Withdraw form
     - [ ] Receive view
     - [ ] Transactions history
       - [ ] Transactions history list
       - [ ] Transaction details page
     - [ ] Share button
     - [ ] Disable button
     - [ ] Rewards page (for KMD)
     - [ ] Faucet view (for RICK and MORTY)
 - **DEX**
   - [ ] Simple form
   - [ ] Advanced form
   - [ ] Multi-order form
   - [ ] Active orders list
    - [ ] Maker order details page
    - [ ] Active swap details page
   - [ ] History list
     - [ ] Successful swap details page
     - [ ] Failed swap details page
 - **Markets**
   - [ ] Prices
    - [ ] Candlestick charts
   - [ ] Orderbooks
    - [ ] Coin selector popup
    - [ ] Order details page
 - **Feed**
   - [ ] Overscroll to update
 - **Drawer (More button)**
   - [ ] Language switcher
   - [ ] Currency switcher
   - [ ] Hide balance switcher
   - [ ] Dark/light theme
   - [ ] Log Out
 - **Settings**
   - [ ] Log Out on Exit
   - [ ] Sound settings page
   - [ ] Activate pin
   - [ ] Activate biometrics
   - [ ] Camo pin
   - [ ] Change pin
   - [ ] Share log file
   - [ ] View seed and priv keys
   - [ ] Export
   - [ ] Import
     - [ ] Import single swap
   - [ ] Delete logs
   - [ ] Enable all test coins
   - [ ] Check for updates
   - [ ] Delete wallet
 - **Address book**
    - [ ] Add/edit contact
    - [ ] Add/edit address
    - [ ] Search for contact/address
 - **Help**
   - [ ] Support link
   - [ ] FAQ's section
 - **Lock screen**
   - [ ] Pin page
   - [ ] Biometrics
 - **Services**
   - [ ] Notifications
     - [ ] Swap status update
     - [ ] New transactions
   

## 3. How to run tests

 For more detailed `flutter test` output add verbose flag after command (`-v` `-vv`)

### 3.1. Mac + iOS (physical iPhone)
> Before you begin, delete all previously installed versions of application from device

#### 3.1.1. Create Wallet
 - Open terminal in the project's root folder 
 - Connect physical iPhone with cable
 - Type and run the test file in the terminal:
```bash
flutter test integration_test/runners/create_wallet.dart
```
 - The test build and opens AtomicDEX from the Splash Screen.
 
 The tests: 
 - From the Splash screen, it navigates to the welcome screen and the create wallet is clicked, which then goes to the enter wallet name page
 - Enter a unique name of your wallet
 - Press "LET'S GET SET UP!" button and opens the page with your new Seed Phrase
 - Press the reload icon to generate new Seed Phrase
 - Press the copy icon to copy the newly generated Seed Phrase
 - Press "NEXT" button to open the "check seed phrase" page
 - Press the "GO BACK AND CHECK AGAIN" and returns to "your new seed phrase" page 
 - Press "NEXT" button to open the "check seed phrase" page
 - Choose the wrong word, nothing will happen, user can't continue
 - Choose the right word, the "CONTINUE" button changed color (activated), user can go to the next step
 - Enter password under 12 characters, or without one lower-case or on upper-case, or without  one special symbol, but it is impossible to create a password that does not meet the requirements
 - Enter confirm password, An error opens shows in the enter password field
 - Enter correct password, and move to next input
 - Press eye icon, to hide and show password
 - Press "confirm password" button and it opens "Disclaimer & ToS" page
 - Tries to press "NEXT" without all checkbox's, without one of them, but unable to continue without accepted
 - Accept all checkbox's and long presses the down icon to scroll the page down, then "next" button changed color (activated), you can go to the next step
 - Press "next" button and opened "create PIN" page 
 - Enter any 6 digits PIN and go to "confirm PIN code"
 - Enter discrepant PIN, and shows "Error, please try again"
 - Enter correct PIN again and Wallet is successfully created. 

#### 3.1.2. Restore Wallet
- Open terminal in the project's root folder
- Type and run the test file in the terminal:
```bash
flutter test integration_test/runners/restore_wallet.dart
```
 - The test build and opens AtomicDEX from the Splash Screen.
 
 The tests: 
 - From the Splash screen, it navigates to the welcome screen and the restore wallet is clicked, which then goes to the enter wallet name page
 - Enters uniques name of your wallet
 - Press "LET'S GET SET UP!" button and opens the page with your new Seed Phrase
 - Enter the wrong or non-existent seed phrase, unable to confirm with wrong seed phrase
 - input your seed phrase, the "confirm" button color changed (activated), can go to the next step
 - Press eye icon, entered seed becomes either visible or hidden on the press, no animation issues present
 - Press confirm Seed Button, to go to the password page
 - Enter password under 12 characters, or without one lower-case or on upper-case, or without  one special symbol, but it is impossible to create a password that does not meet the requirements
 - Enter confirm password, An error opens shows in the enter password field
 - Enter correct password, and move to next input
 - Press eye icon, to hide and show password
 - Press "confirm password" button and it opens "Disclaimer & ToS" page
 - Tries to press "NEXT" without all checkbox's, without one of them, but unable to continue without accepted
 - Accept all checkbox's and long presses the down icon to scroll the page down, then "next" button changed color (activated), you can go to the next step
 - Press "next" button and opened "create PIN" page 
 - Enter any 6 digits PIN and go to "confirm PIN code"
 - Enter discrepant PIN, and shows "Error, please try again"
 - Enter correct PIN again and Wallet is successfully restored. 

#### 3.1.4. Add/Edit address 
Resolves `Remove address duplicate button`
- Open terminal in the project's root folder
- Connect real device and replace the `device_id` with the device's id in ./execute_integration.sh
- Type and run the test file in the terminal:
```bash
flutter test integration_test/runners/add_address.dart
```
- The test build and opens AtomicDEX from the Splash Screen and restores a wallet
- On the main page, Press the more icon on the bottom nav bar, and the drawer opens up
- Press Address book button, and the address book page opens up
- Click the add icon button to add an address on the page and the Add Address page opens up
- Click the add address text-button to select the coin type on the page and the choose coins dialog comes up
- Select 'AXE' as the coin type, and the drawer closes
- Input the address name and the address field
- Tap on save button, the Page goes back to the previous page with the item saved
- Select on the Item, to make it expanded and click on the address, It opens up the edit address
- Click the add address text-button to select the coin type on the page and the choose coins dialog comes up
- Select 'AXE' as the coin type, and the drawer closes,
- Edit the address name and the address field
- Tap on save button, the Page goes back to the previous page with the item saved

#### 3.2 Run all tests

- Open terminal
- Run `flutter devices` to obtain your iPhone's device id
- Replace `YOUR_DEVICE_ID` with your device's id in ./execute_integration.sh
- Type and run the execute_integration.sh file in the terminal:
```bash
/bin/zsh ./execute_integration.sh
```
- All the tests are run from 3.1.1 to 3.1.2