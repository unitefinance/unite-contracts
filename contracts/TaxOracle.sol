// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// UNITE FINANCE


contract TaxOracle is Ownable {
    using SafeMath for uint256;

    IERC20 public kitty;
    IERC20 public wavax;
    address public pair;

    constructor(
        address _kitty,
        address _wavax,
        address _pair
    ) public {
        require(_kitty != address(0), "kitty address cannot be 0");
        require(_wavax != address(0), "wavax address cannot be 0");
        require(_pair != address(0), "pair address cannot be 0");
        kitty = IERC20(_kitty);
        wavax = IERC20(_wavax);
        pair = _pair;
    }

    function consult(address _token, uint256 _amountIn) external view returns (uint144 amountOut) {
        require(_token == address(kitty), "token needs to be kitty");
        uint256 kittyBalance = kitty.balanceOf(pair);
        uint256 wavaxBalance = wavax.balanceOf(pair);
        return uint144(kittyBalance.mul(_amountIn).div(wavaxBalance));
    }

    function getUniteBalance() external view returns (uint256) {
	return kitty.balanceOf(pair);
    }

    function getBtcbBalance() external view returns (uint256) {
	return wavax.balanceOf(pair);
    }

    function getPrice() external view returns (uint256) {
        uint256 kittyBalance = kitty.balanceOf(pair);
        uint256 wavaxBalance = wavax.balanceOf(pair);
        return kittyBalance.mul(1e18).div(wavaxBalance);
    }

    function setUnite(address _kitty) external onlyOwner {
        require(_kitty != address(0), "kitty address cannot be 0");
        kitty = IERC20(_kitty);
    }

    function setWavax(address _wavax) external onlyOwner {
        require(_wavax != address(0), "wavax address cannot be 0");
        wavax = IERC20(_wavax);
    }

    function setPair(address _pair) external onlyOwner {
        require(_pair != address(0), "pair address cannot be 0");
        pair = _pair;
    }
}