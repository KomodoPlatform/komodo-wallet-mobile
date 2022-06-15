# Integration Testing

## 1. General info

 - Integration testing is implemented using Flutter built-in [integration_test](https://github.com/flutter/flutter/tree/main/packages/integration_test) package.
 - New tests should be added, if possible, for every new issue as a part of corresponding PR, to provide coverage for specific bug/feature. This way we'll, hopefully, expand test coverage in a natural manner.
 - Coverage (and structure, if needed) should be updated in table below.

## 2. App structure and test coverage

 - **Main screen, Wallets manager**
   - [x] Create wallet
   - [x] Restore wallet
   - [ ] Login to wallet
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

### 3.1. Mac + iOs (physical iPhone)
Coming soon...