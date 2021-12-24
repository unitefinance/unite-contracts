// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "./owner/Operator.sol";
import "./interfaces/ITaxable.sol";
import "./interfaces/IUniswapV2Router.sol";
import "./interfaces/IERC20.sol";

// UNITE FINANCE
contract TaxOfficeV2 is Operator {
    using SafeMath for uint256;

    address public kitty;
    address public base;
    address public router;

    mapping(address => bool) public taxExclusionEnabled;

    constructor(address _kitty, address _base, address _router) public {
        require(_kitty != address(0), "Address cannot be 0");
        kitty = _kitty;

        require(_base != address(0), "Address cannot be 0");
        base = _base;

        require(_router != address(0), "Address cannot be 0");
        router = _router;
    }

    function setTaxTiersTwap(uint8 _index, uint256 _value) public onlyOperator returns (bool) {
        return ITaxable(kitty).setTaxTiersTwap(_index, _value);
    }

    function setTaxTiersRate(uint8 _index, uint256 _value) public onlyOperator returns (bool) {
        return ITaxable(kitty).setTaxTiersRate(_index, _value);
    }

    function enableAutoCalculateTax() public onlyOperator {
        ITaxable(kitty).enableAutoCalculateTax();
    }

    function disableAutoCalculateTax() public onlyOperator {
        ITaxable(kitty).disableAutoCalculateTax();
    }

    function setTaxRate(uint256 _taxRate) public onlyOperator {
        ITaxable(kitty).setTaxRate(_taxRate);
    }

    function setBurnThreshold(uint256 _burnThreshold) public onlyOperator {
        ITaxable(kitty).setBurnThreshold(_burnThreshold);
    }

    function setTaxCollectorAddress(address _taxCollectorAddress) public onlyOperator {
        ITaxable(kitty).setTaxCollectorAddress(_taxCollectorAddress);
    }

    function excludeAddressFromTax(address _address) external onlyOperator returns (bool) {
        return _excludeAddressFromTax(_address);
    }

    function _excludeAddressFromTax(address _address) private returns (bool) {
        if (!ITaxable(kitty).isAddressExcluded(_address)) {
            return ITaxable(kitty).excludeAddress(_address);
        }
    }

    function includeAddressInTax(address _address) external onlyOperator returns (bool) {
        return _includeAddressInTax(_address);
    }

    function _includeAddressInTax(address _address) private returns (bool) {
        if (ITaxable(kitty).isAddressExcluded(_address)) {
            return ITaxable(kitty).includeAddress(_address);
        }
    }

    function taxRate() external returns (uint256) {
        return ITaxable(kitty).taxRate();
    }

    function addLiquidityTaxFree(
        address token,
        uint256 amtUnite,
        uint256 amtToken,
        uint256 amtUniteMin,
        uint256 amtTokenMin
    )
        external
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        require(amtUnite != 0 && amtToken != 0, "amounts can't be 0");
        _excludeAddressFromTax(msg.sender);

        IERC20(kitty).transferFrom(msg.sender, address(this), amtUnite);
        IERC20(token).transferFrom(msg.sender, address(this), amtToken);
        _approveTokenIfNeeded(kitty, router);
        _approveTokenIfNeeded(token, router);

        _includeAddressInTax(msg.sender);

        uint256 resultAmtUnite;
        uint256 resultAmtToken;
        uint256 liquidity;
        (resultAmtUnite, resultAmtToken, liquidity) = IUniswapV2Router(router).addLiquidity(
            kitty,
            token,
            amtUnite,
            amtToken,
            amtUniteMin,
            amtTokenMin,
            msg.sender,
            block.timestamp
        );

        if (amtUnite.sub(resultAmtUnite) > 0) {
            IERC20(kitty).transfer(msg.sender, amtUnite.sub(resultAmtUnite));
        }
        if (amtToken.sub(resultAmtToken) > 0) {
            IERC20(token).transfer(msg.sender, amtToken.sub(resultAmtToken));
        }
        return (resultAmtUnite, resultAmtToken, liquidity);
    }

    function addLiquidityETHTaxFree(
        uint256 amtUnite,
        uint256 amtUniteMin,
        uint256 amtEthMin
    )
        external
        payable
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        require(amtUnite != 0 && msg.value != 0, "amounts can't be 0");
        _excludeAddressFromTax(msg.sender);

        IERC20(kitty).transferFrom(msg.sender, address(this), amtUnite);
        _approveTokenIfNeeded(kitty, router);

        _includeAddressInTax(msg.sender);

        uint256 resultAmtUnite;
        uint256 resultAmtEth;
        uint256 liquidity;
        (resultAmtUnite, resultAmtEth, liquidity) = IUniswapV2Router(router).addLiquidityETH{value: msg.value}(
            kitty,
            amtUnite,
            amtUniteMin,
            amtEthMin,
            msg.sender,
            block.timestamp
        );

        if (amtUnite.sub(resultAmtUnite) > 0) {
            IERC20(kitty).transfer(msg.sender, amtUnite.sub(resultAmtUnite));
        }
        return (resultAmtUnite, resultAmtEth, liquidity);
    }

    function setTaxableUniteOracle(address _kittyOracle) external onlyOperator {
        ITaxable(kitty).setUniteOracle(_kittyOracle);
    }

    function transferTaxOffice(address _newTaxOffice) external onlyOperator {
        ITaxable(kitty).setTaxOffice(_newTaxOffice);
    }

    function taxFreeTransferFrom(
        address _sender,
        address _recipient,
        uint256 _amt
    ) external {
        require(taxExclusionEnabled[msg.sender], "Address not approved for tax free transfers");
        _excludeAddressFromTax(_sender);
        IERC20(kitty).transferFrom(_sender, _recipient, _amt);
        _includeAddressInTax(_sender);
    }

    function setTaxExclusionForAddress(address _address, bool _excluded) external onlyOperator {
        taxExclusionEnabled[_address] = _excluded;
    }

    function _approveTokenIfNeeded(address _token, address _router) private {
        if (IERC20(_token).allowance(address(this), _router) == 0) {
            IERC20(_token).approve(_router, type(uint256).max);
        }
    }
}
