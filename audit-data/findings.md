### [S-#] Storing passwords on-chain makes it visible to anyone, it is no longer private.

**Description:** All data stored on-chain is visible to anyone, and can be read directly from the blockchain. The `PasswordStore::_password` variable is intended to be a private variable and only accessed through the `PasswordStore::getPassword` function, which is intended to be called only by the owner.

We show one such method of reading any data off chain below. 

**Impact:** Anyone can read any data stored on-chain, severely breaking the functionality of the protocol.

**Proof of Concept:**

The below test case show how anyone can read any data stored on the blockchain.

1. Create a locally running chain
```
make anvil
```
2. Deploy contract to the chain
```
make deploy
```
3. Run the storage tool

We use `1` because it is the storage slot of the variable `s_password`

```
cast storage <ADRESS HERE> 1 --rpc-url http://127.0.0.1:8545
```

You'll get output like below

```
0x6d7950617373776f726400000000000000000000000000000000000000000014
```

You can parse that hex to string with

```
cast parse-bytes32-string 0x6d7950617373776f726400000000000000000000000000000000000000000014
```

And get output of

```
myPassword
```

**Recommended Mitigation:** Due to this, overall architecture of the protocol need to be rethought. One could encrypt the password off-chain and then store the encrypted password on-chain. But this would need the user to remember another password offchain to decrypt the password. However, it's highly advised to remove the view function as you wouldn't want the user to accidently send a transaction with the password that decrypts your password.



### [S-#] `PasswordStore::setPassword` has no access control, anyone can call it.

**Description:** The `PasswordStore::setPassword` function is set to be an `external` function, however, natspec of the function and overall architecture of the protocol suggest `This function allows only the owner to set a new password.`

```javascript
    function setPassword(string memory newPassword) external {
>@        // @audit - There is no access control
        s_password = newPassword;
        emit SetNetPassword();
    }
```

**Impact:** Anyone can call `setPassword` function and set/change a new password severely breaking contract functionality.

**Proof of Concept:** Add the following to the `PasswordStore.t.sol` test file.

<details>
<summary>Code</summary>

```javascript
    function test_anyone_can_set_password(address randomAddress) public {
        vm.assume(randomAddress != owner);
        vm.prank(randomAddress);
        string memory expectedPassword = "notAOwnersPassword";
        passwordStore.setPassword(expectedPassword);

        vm.prank(owner);
        string memory actualPassword = passwordStore.getPassword();
        assertEq(actualPassword, expectedPassword);
    }
```

</details>

**Recommended Mitigation:** Add an access control conditional to the `setPassword` function to ensure only the owner can call it.

```javascript
    if(`owner` != msg.sender) {
        revert PasswordStore_NotOwner();
    }
```


### [S-#] The `PasswordStore::getPassword` function natspec suggests a parameter that doesn't exist, causing the natspec to be incorrect.

**Description:** The `PasswordStore::getPassword` function signature is `getPassword()` while the natspec suggests it should be `getPassword(string)`.

**Impact:** The natspec is incorrect

**Recommended Mitigation:** Remove the incorrect natspec line.

```diff
-    * @param newPassword The new password to set.
```