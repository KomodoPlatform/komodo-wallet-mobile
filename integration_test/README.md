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
   - [x] Simple form
   - [x] Advanced form
   - [x] Multi-order form
   - [x] Active orders list
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

#### 3.1.5. Create Simple Swap
- Open terminal in the project's root folder
- Type and run the test file in the terminal:
```bash
flutter test integration_test/runners/create_simple_swap.dart
```
- The test build and opens AtomicDEX from the Splash Screen and restores a wallet

The tests:
- From the Coins Page, press the Add Asset button
- Enter 'MORTY' into the search field, and MORTY is selected
- Enter 'RICK' into the search field, and RICK is selected
- Enter '' into the search field, and the field is cleared
- Press the confirm asset button and the coins are activated and directed back to Coins Page
- Press the dex icon on the bottom nav bar, and the dex page is opened
- Press MORTY on the sell part and input 0.1 as amount and the buy section loads
- Press RICK on the buy part and the amount equivalent generates
- Press the 'Next' button and the swap summary generates
- Press the 'Confirm Swap' button and the swap begins
- Press the back button to go to the Dex page
- Press the Order tab and the Order page is opened to see all swaps

#### 3.1.6. Cancel a Simple Swap
- Open terminal in the project's root folder
- Type and run the test file in the terminal:
```bash
flutter test integration_test/runners/cancel_swap.dart
```
- The test build and opens AtomicDEX from the Splash Screen and restores a wallet

The tests:
- The swap flow is repeated and a swap is created
- From the Order Page, Press the Cancel button on the swap item and the dialog opens
- Press the 'Yes' button and the Swap is cancelled
- Press the Swap tab and the Swap page is opened to create a swap
- The swap flow is repeated and a swap is created
- From the Order Page, Press the Cancel button on the swap item and the dialog opens
- Press the 'No' button and the Swap remains
- Press the Swap tab and the Swap page is opened to create a swap
- The swap flow is repeated and a swap is created
- From the Order Page, Press the Cancel button on the swap item and the dialog opens
- Select the 'Dont show again' checkbox and Press the 'Yes' button and the Swap is cancelled
- Press the Swap tab and the Swap page is opened to create a swap
- The swap flow is repeated and a swap is created
- From the Order Page, Press the Cancel button on the swap item is cancelled immediately

#### 3.1.7. Create an Advanced Swap
- Open terminal in the project's root folder
- Type and run the test file in the terminal:
```bash
flutter test integration_test/runners/create_advanced_swap.dart
```
- The test build and opens AtomicDEX from the Splash Screen and restores a wallet

The tests:
- From the Coins Page, press the Add Asset button
- Enter 'MORTY' into the search field, and MORTY is selected
- Enter 'RICK' into the search field, and RICK is selected
- Enter '' into the search field, and the field is cleared
- Press the confirm asset button and the coins are activated and directed back to Coins Page
- Press the dex icon on the bottom nav bar, and the dex page is opened
- Press the 'Advanced' tab to move to the Advanced section on dex page
- Click on the sell button coin dropdown and a dialog is opened
- Select MORTY from the list and it is entered in the drop down
- Input 1 on the text field of the sell coin
- Click on the receive button coin dropdown and a dialog is opened
- Select RICK from the list of orders and the rick's order page is opened
- Select the first one and a dialog to confirm the order is opened
- Confirm the order and it is entered in the receive drop down
- Input 1 on the text field of the sell coin
- Press the next button to move to the confirm advanced order page
- Press the cancel button to return to the advanced screen
- Press clear to clear the whole order and every field and buttons are cleared
- Click on the sell button coin dropdown and a dialog is opened
- Select MORTY from the list and it is entered in the drop down
- Input 1 on the text field of the sell coin
- Click on the receive button coin dropdown and a dialog is opened
- Select RICK from the list of orders and the rick's order page is opened
- Select the first one and a dialog to confirm the order is opened
- Confirm the order and it is entered in the receive drop down
- Input 1 on the text field of the sell coin
- Press the next button to move to the confirm advanced order page
- Press the start button to confirm the order and the order moves to the details page
- Press back button to go to the dex page
- Press the Order tab to move to the orders page to see the newly created order

#### 3.1.8. Create an Multi Swap
- Open terminal in the project's root folder
- Type and run the test file in the terminal:
```bash
flutter test integration_test/runners/create_advanced_swap.dart
```
- The test build and opens AtomicDEX from the Splash Screen and restores a wallet

The tests:
- From the Coins Page, Press the more icon on the bottom nav bar, and the drawer is opened
- Press the settings button and the settings page is opened
- Scroll down the page until the 'enable test coin' item is visible
- Click on the 'enable test coin' item to enable the item
- Press back button to go back to the Home page
- From the Coins Page, Press the portfolio icon on the bottom nav bar to confirm we are on the Portfolio page
- From the Coins Page, press the Add Asset button
- Enter 'MORTY' into the search field, and MORTY is selected
- Enter 'RICK' into the search field, and RICK is selected
- Enter 'tQTUM' into the search field, and tQTUM is selected
- Enter '' into the search field, and the field is cleared
- Press the confirm asset button and the coins are activated and directed back to Coins Page with the 3 coins activated
- Press the dex icon on the bottom nav bar, and the dex page is opened
- Press the 'Multi' tab to move to the Advanced section on dex page
- Click on the sell button coin dropdown and a dialog is opened
- Select MORTY from the list and it is entered in the drop down
- Input 1 on the text field of the sell coin
- Click on 'Rick' item to enable the item
- Enter 0.1 into 'Rick' item textfield
- Click on 'tQTUM' item to enable the item
- Enter 0.3 into 'tQTUM' item textfield
- Press the next button to move to the confirm multi order page
- Press the start button to confirm the order and the order moves to the order page immediately and the newly created order is seen

#### 3.1.9 Run all wallet tests

- Open terminal
- Run `flutter devices` to obtain your iPhone's device id
- Replace `YOUR_DEVICE_ID` with your device's id in ./execute_integration.sh
- Type and run the execute_integration.sh file in the terminal:
```bash
flutter test integration_test/tests/wallet_tests.dart
```
- All the tests are run from 3.1.1 to 3.1.2

#### 3.2.0 Run all swap tests

- Open terminal
- Run `flutter devices` to obtain your iPhone's device id
- Replace `YOUR_DEVICE_ID` with your device's id in ./execute_integration.sh
- Type and run the execute_integration.sh file in the terminal:
```bash
flutter test integration_test/tests/swap_tests.dart
```
- All the tests are run from 3.1.5 to 3.1.8
