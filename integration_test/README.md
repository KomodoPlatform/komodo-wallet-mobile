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

### 3.1. Mac + iOS (physical iPhone)
#### 3.1.1. Create Wallet
 - Open terminal 
 - Type and run the execute_integration.sh file in the terminal:
```bash
/bin/zsh ./execute_integration.sh
```
 - The test build and opens AtomicDEX from the Splash Screen.
 
 The tests: 
 - From the Splash screen, it navigates to the welcome screen and the create wallet is clicked, which then goes to the enter wallet name page
 - Enter a unique name of your wallet
 - Press "LET'S GET SET UP!" button and opens the page with your new Seed Phrase
 - Press the reload icon to generate new Seed Phrase
 - Press the copy icon to copy the newly generated Seed Phrase
 - Press "NEXT" button to open the "check seed phrase" page
 - Press the "GO BACK AND CHACK AGAIN" and returns to "your new seed phrase" page 
 - Press "NEXT" button to open the "check seed phrase" page
 - Choose the wrong word, nothing will hepen, user can't continue
 - Choose the right word, the "CONTINUE" button changed color (activated), user can go to the next step
 - Enter password under 12 characters, or without one lower-case or on upper-case, or without  one spetial symbol, but it    is impossible to create a password that does not meet the requirements
 - Enter confirm password, An error opens shows in the enter password field
 - Enter correct password, and move to next input
 - Press eye icon, to hide and show passwod
 - Press "confirm password" button and it opens "Disclaimer & ToS" page
 - Tries to press "NEXT" without all checkbox's, without one of them, but unable to continue without accepted
 - Accept all checkbox's and long presses the down icon to scroll the page down, then "next" button changed color (activated), you can go to the next step
 - Press "next" button and opened "create PIN" page 
 - Enter any 6 digits PIN and go to "confirm PIN code"
 - Enter discrepant PIN, and shows "Eror, please try again"
 - Enter correct PIN again and Wallet is successfully created. 

#### 3.1.2. Restore Wallet
 - Open terminal 
 - Type and run the execute_integration.sh file in the terminal:
```bash
/bin/zsh ./execute_integration.sh
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
 - Enter password under 12 characters, or without one lower-case or on upper-case, or without  one spetial symbol, but it    is impossible to create a password that does not meet the requirements
 - Enter confirm password, An error opens shows in the enter password field
 - Enter correct password, and move to next input
 - Press eye icon, to hide and show passwod
 - Press "confirm password" button and it opens "Disclaimer & ToS" page
 - Tries to press "NEXT" without all checkbox's, without one of them, but unable to continue without accepted
 - Accept all checkbox's and long presses the down icon to scroll the page down, then "next" button changed color (activated), you can go to the next step
 - Press "next" button and opened "create PIN" page 
 - Enter any 6 digits PIN and go to "confirm PIN code"
 - Enter discrepant PIN, and shows "Eror, please try again"
 - Enter correct PIN again and Wallet is successfully restored. 

