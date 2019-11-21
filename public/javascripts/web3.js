var web3 = new Web3();
web3.setProvider(new Web3.providers.HttpProvider('http://localhost:8545'));

const contract_address = "";
const abi = 

let carTrade = new web3.eth.Contract(abi, contract_address);

$(document).ready(function() {
	startDapp();
})

var startDapp = async function() {
}


var getBalance = function() {
}

var getName = async function() {
}

var registerName = async function() {
}


var registerMyCar = async function() {
}

var sellMyCar = async function() {
}

var buyUserCar = async function() {
}

var getMyCars = async function() {
}

var getRegisteredCars = async function() {
}

var getSellMyCars = async function() {
}

var getCarsOnSale = async function() {

}

var getBuyUsersCar = async function() {

}

