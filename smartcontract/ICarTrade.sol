pragma solidity ^0.5;
pragma experimental ABIEncoderV2;


contract ICarTrade{
    struct Car{
        uint number;
        string owner_name;
        string make;
        string model;
        string color;
        address payable owner;
    }
    
    struct Order{
        Car car;
        uint price;
        string status;
    }
    
    function registerCar(string memory make, string memory model, string memory color) public;
    function registerName(string memory name) public;
    function sellMyCar(uint cnumber, uint price) public;
    function buyUserCar(uint orderedcnumber) payable public;
    function balanceTransfer(address payable seller, uint price) payable public;
    function changeCarOwner(uint cnumber, address addr) public;
    function getMyCars() public view returns(Car[] memory);
    function getName() public view returns(string memory);
    function getAllRegisteredCar() public view returns(Car[] memory);
    function getAllOrderedCar() public view returns(Order[] memory);
}