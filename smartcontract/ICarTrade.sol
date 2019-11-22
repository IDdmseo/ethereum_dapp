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

    /* variables */
    uint regCarIdx = 0;
    mapping(address => string) nameof;
    mapping(string => address payable) addrof;
    mapping(uint => Order) orderof;

    Order[] regOrders;
    Car[] regCars;
    
    function registerCar(string memory make, string memory model, string memory color) public {
        regCars.push(Car(regCarIdx, nameof[msg.sender], make, model, color, msg.sender));
        regCarIdx += 1;
    }

    function registerName(string memory name) public {
        nameof[msg.sender] = name;
        addrof[name] = msg.sender;
    }

    function sellMyCar(uint cnumber, uint price) public {
        Order memory newOrder;
        newOrder = Order(regCars[cnumber], price, "sale");
        regOrders.push(newOrder);
        orderof[cnumber] = newOrder;
    }

    function buyUserCar(uint orderedcnumber) payable public{
        // 1. 해당 번호의 주문서를 검색
        Order storage buyCar = regOrders[0];
        for (uint i = 0; i <= regOrders.length; i++){
            if(orderedcnumber != regOrders[i].car.number)
                continue;
            else {
                buyCar = regOrders[i];
                break;
            }
        }
        // 2. 주문서의 가격과 주문자의 잔액을 대조
            // 2-1. 잔액이 조건에 충족될 경우 transfer 수행
            // 2-2. 아닐 경우 return;
        require(buyCar.price < msg.sender.balance);
        balanceTransfer(addrof[buyCar.car.owner_name], buyCar.price);
        // 3. 차량의 소유 주 및 주문서 상태 변경
        changeCarOwner(buyCar.car.number, msg.sender);
    }

    function balanceTransfer(address payable seller, uint price) payable public {
        seller.transfer(price);
    }

    function changeCarOwner(uint cnumber, address addr) public {
        orderof[cnumber].car.owner_name = nameof[addr];
        orderof[cnumber].status = "done";
    }

    function getMyCars() public view returns(Car[] memory){
        Car[] memory myCar;
        for (uint i = 0; i <= regCars.length; i++) {
            if (nameof[msg.sender] != regCars[i].owner_name)
                continue;
            else 
                myCar.push(regCars[i]);    
        }

        require(myCar.length > 0);
        return myCar;
    }

    function getName() public view returns(string memory){
        require(nameof[msg.sender].length > 0);
        return nameof[msg.sender];   
    }
    function getAllRegisteredCar() public view returns(Car[] memory){
        require(regCars.length > 0);
        return regCars;
    }
    function getAllOrderedCar() public view returns(Order[] memory){
        require(regOrders.length > 0);
        return regOrders;
    }
}