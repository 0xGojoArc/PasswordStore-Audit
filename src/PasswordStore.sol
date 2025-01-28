// SPDX-License-Identifier: MIT
pragma solidity 0.8.18; 

/*
 * @author not-so-secure-dev
 * @title PasswordStore
 * @notice This contract allows you to store a private password that others won't be able to see. 
 * You can update your password at any time.
 */
 
contract PasswordStore {
    error PasswordStore__NotOwner();

    /*//////////////////////////////////////////////////̀////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/

    address private s_owner;
    // @audit s_password is actually not private variable. Not a safe place to secure the password
    string private s_password;

    /*//////////////////////////////////////////////////////////////
                            EVENTS
    //////////////////////////////////////////////////////////////*/


    // i there's a typo in the event name
    event SetNetPassword();

    constructor() {
        s_owner = msg.sender; // s_owner is the one is owner of the contract
    }

    /*
     * @notice This function allows only the owner to set a new password.
     * @param newPassword The new password to set.
     */

     // @audit any user can set a password
     //missing access control
    function setPassword(string memory newPassword) external {
        s_password = newPassword;
        emit SetNetPassword();
    }

    /*
     * @notice This allows only the owner to retrieve the password.
     //@audit there is not newPassword parameter!
     * @param newPassword The new password to set.
     */
    function getPassword() external view returns (string memory) {
        if (msg.sender != s_owner) {
            revert PasswordStore__NotOwner();
        }
        return s_password;
    }
}
