pragma solidity ^0.5;
pragma experimental ABIEncoderV2;

contract ICarTrade{
    /* structure */
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
    uint regCar_idx = 0;
    uint[] orderOfKey; // key_idx => carnumber
    string[] alluser;

    mapping(address => string) public nameOf; // address => name
    mapping(string => Car[]) public registeredCars; // name => car
    mapping(uint => Order) public registeredOrders; // carnumber => Order

    /* function */
    /* 차량을 등록하는 함수, 단 판매 목록에 등록은 아님 */ 
    function registerCar(string memory make, string memory model, string memory color) public {
        string memory ownerName = getName();
        Car memory newCar = Car(regCar_idx, ownerName, make, model, color, msg.sender);
        registeredCars[ownerName].push(newCar);
        regCar_idx += 1;
    }

    /* 이름 등록 작업 */
    function registerName(string memory name) public {
        nameOf[msg.sender] = name;
        alluser.push(name);
    }

    /* 자신의 등록된 차를 오더 목록에 올리는 함수 */
    function sellMyCar(uint cnumber, uint price) public {
        string memory ownerName = getName();
        Order memory newOrder;

        for(uint i = 0; i < registeredCars[ownerName].length; i++){
            if(registeredCars[ownerName][i].number != cnumber)
                continue;
            else {
                newOrder = Order(registeredCars[ownerName][i], price, "sale");
                registeredOrders[cnumber] = newOrder;
                orderOfKey.push(cnumber);
            }
        }
    }

    /* 오더 목록에 있는 차량을 등록번호를 통해 구매하는 함수 */
    function buyUserCar(uint orderedcnumber) payable public{
        // 1. 번호에 대응하는 판매 차량을 get
        // 2. transaction 발생
        // 3. transaction이 유효 할경우 소유 주 변경 작업 수행
        address payable car_seller = registeredOrders[orderedcnumber].car.owner;
        uint orderPrice = registeredOrders[orderedcnumber].price;

        require(msg.sender.balance > orderPrice, "not enough ether to buy car\n");
        balanceTransfer(car_seller, orderPrice);
        changeCarOwner(orderedcnumber, msg.sender);
    }

    /* 오더 시 차량의 소유주에게 이더를 송금하는 함수 */
    function balanceTransfer(address payable seller, uint price) payable public {
        seller.transfer(price);
    }

    /* 차량의 소유주를 변경하는 함수 */ 
    function changeCarOwner(uint cnumber, address payable addr) public {
        Order memory changeinfo = registeredOrders[cnumber];
        string memory originOwner = changeinfo.car.owner_name;
        Car[] memory deleteCar = registeredCars[originOwner];
        uint old_length = registeredCars[originOwner].length;

        /* 기존 소유 주의 등록 차량 목록에서 삭제 */
        for(uint i = 0; i < deleteCar.length; i++) {
            if(deleteCar[i].number != cnumber)
                continue;
            else { // idx shift 부분
                for(uint idx = i; idx < deleteCar.length - 1; idx++)
                    deleteCar[idx] = deleteCar[idx + 1];
                delete deleteCar[deleteCar.length - 1];
                registeredCars[originOwner].length = old_length - 1;
            }
        }
        
        /* 차량 소유주 변경 및 새 소유주 등록 차량 목록으로 이전 */
        changeinfo.car.owner_name = getName();
        changeinfo.car.owner = addr;
        changeinfo.status = "done";
        registeredCars[getName()].push(changeinfo.car);
    }

    /* 등록된 자신의 모든 차량을 불러오는 함수 */
    function getMyCars() public view returns(Car[] memory){
        string memory name = getName();
        return registeredCars[name];
    }

    /* 주소를 key로 이름을 불러오는 작업 */
    function getName() public view returns(string memory){
        return nameOf[msg.sender];
    }

    /* 등록된 모든 차량의 목록을 불러오는 함수, 단 판매중인 차량은 등록된 목록에 표시 하지 않는다? */
    function getAllRegisteredCar() public view returns(Car[] memory){
        uint idx = 0;
        Car[] memory showCars;

        for(uint i = 0; i < alluser.length; i++){ // 
            for(uint j = 0; j < registeredCars[alluser[i]].length; j++){
                for(uint k = 0; k < orderOfKey.length; k++){
                    if(registeredCars[alluser[i]][j].number != orderOfKey[k]){
                        showCars[idx] = registeredCars[alluser[i]][j];
                        idx += 1;
                    } else
                        continue;
                }
            }
        }

        require(showCars.length > 0, "there are no registeredCars\n");
        return showCars;
    }
    
    /* 주문 목록의 차량의 목록을 모두 불러오는 함수, 단 구매 완료된 차량은 표시 X */
    function getAllOrderedCar() public view returns(Order[] memory){
        uint idx = 0;
        string memory compare;
        Order[] memory showOrders;
        Order memory search;
                
        require(orderOfKey.length > 0, "there are no orders in list\n");
        for(uint i = 0; i <= orderOfKey.length; i++){
            compare = registeredOrders[orderOfKey[i]].status;
            if(keccak256(bytes(compare)) != keccak256(bytes("sale")))
                continue;
            else {
                search = registeredOrders[orderOfKey[i]];
                showOrders[idx] = search;
                idx += 1;
            }
        }
        require(showOrders.length > 0, "there are no available orders in list\n");
        return showOrders;
    }
}