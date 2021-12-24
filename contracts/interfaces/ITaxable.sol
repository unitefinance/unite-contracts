// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface ITaxable {
    function setTaxTiersTwap(uint8 _index, uint256 _value) external returns (bool);

    function setTaxTiersRate(uint8 _index, uint256 _value) external returns (bool);

    function enableAutoCalculateTax() external;

    function disableAutoCalculateTax() external;

    function taxRate() external returns (uint256);

    function setTaxCollectorAddress(address _taxCollectorAddress) external;

    function setTaxRate(uint256 _taxRate) external;

    function setBurnThreshold(uint256 _burnThreshold) external;

    function excludeAddress(address _address) external returns (bool);

    function isAddressExcluded(address _address) external returns (bool);

    function includeAddress(address _address) external returns (bool);

    function setUniteOracle(address _bombOracle) external;

    function setTaxOffice(address _taxOffice) external;
}
