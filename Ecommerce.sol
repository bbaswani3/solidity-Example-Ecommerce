//SPDX-License-Identifier: MIT
pragma solidity >=0.5.0<0.9.0;

contract Ecommerce {
    
    struct Product {
        string title;
        string desc;
        address payable seller;
        uint productId;
        uint price;
        address buyer;
        bool delivered;
    }
    uint counter=1;
    Product[] public products;
    address  payable public manager;

    bool destroyed = false;
    modifier isNotDestroy{
        require(!destroyed,"contract does not Exits");
        _;
    }
    constructor(){
        manager=payable(msg.sender);
    }

    event registered(string title,uint products,address seller);
    event bought(uint productId, address byuer);
    event delivered(uint productId);

    function registerProduct(string memory _title,string memory _desc,uint _price)public isNotDestroy{
        Product memory tempProduct;
        tempProduct.title=_title;
        tempProduct.desc=_desc;
        tempProduct.price=_price * 10**18;
        tempProduct.seller=payable(msg.sender);
        tempProduct.productId=counter;
        products.push(tempProduct);
        counter++;
        emit registered(_title,tempProduct.productId,msg.sender);
    }

    function buy(uint _productId) payable public isNotDestroy{
        require(products[_productId-1].price==msg.value,"Pleaese pay the exact price");
        require(products[_productId-1].seller!=msg.sender,"seller cannot be buyer");
        products[_productId-1].buyer=msg.sender;
        emit bought(_productId,msg.sender);
    }


    function delivery(uint _productId) public isNotDestroy{
        require(products[_productId-1].buyer==msg.sender,"Only byuer can sonfirm");
        products[_productId-1].delivered=true;
        products[_productId-1].seller.transfer(products[_productId-1].price);
        emit delivered(_productId);
    }

    // function destroy() public{
    //     require(msg.sender==manager,"only manager can call this");
    //     selfdestruct(manager);
    // }

    function destroy() public isNotDestroy{
        require(msg.sender==manager);
        manager.transfer(address(this).balance);
        destroyed=true;
    }

    
}
