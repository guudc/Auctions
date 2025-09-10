// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol";

interface IERC1155  {
 


    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;
     function TransferOwnership( uint TokenID,address useraddress)  external;

}
interface IERC20 {

  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint8);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function getOwner() external view returns (address);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address _owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
   //function TransferOwnership( uint TokenID,address useraddress)  external;

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract Auction is ERC1155Receiver  {


mapping(string => Offer) private  Tracking;
  struct  Offer{

    address payable  bidder;
    address payable  seller;
    
    uint  Price;
    uint  bidderdeadline;
    uint  Sellerdeadline;
    bool  bidderConfirmed;
    bool  sellerConfirmed;
    uint tokenID;
    string cancel;
  }

//ERC1155
IERC1155 public  e115;
IERC20 public  erc20;

 constructor(address _nft,address SNCERC20) payable{
       e115 = IERC1155(_nft);
       erc20 = IERC20(SNCERC20);
         
    }
function onERC1155Received(address operator, address from, uint256 tokenId, uint256 value, bytes calldata data) external override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address operator, address from, uint256[] calldata tokenIds, uint256[] calldata values, bytes calldata data) external override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    } 

  //When seller place his NFT for auction we will Send  his NFT from seller address to Escrow wallet address
  function  Seller(address payable _Seller, uint _tokenID , string memory _Tracking  ,uint _Sellerdeadline) external  returns(bool){
    require(bytes(_Tracking).length != 0, "Tracking should not be empty");
      require(_Seller != address(0),"Seller address should not be empty");
      require(_tokenID != 0,"tokenID  should not be empty");
      require(_Sellerdeadline != 0,"Sellerdeadline  should not be  empty");
      // Buyer pays the amount to Escrow
     
      Tracking[_Tracking].seller = _Seller;
      Tracking[_Tracking].tokenID = _tokenID;
      Tracking[_Tracking].Sellerdeadline = _Sellerdeadline;
      Tracking[_Tracking].sellerConfirmed = true;

       e115.safeTransferFrom(_Seller,address(this),_tokenID,1,"0x");
      return true;
  }




  //IF Seller wants to Cancel  this will trigger at web3 revert token to Seller and amount to buyer
    function  EscrowAgentforSellerforCancel(string  memory _Tracking,string  memory cancel)public  returns  (bool) {
     require(bytes(_Tracking).length != 0, "Tracking should not be empty!");
        require(keccak256(bytes(cancel)) == keccak256(bytes("Cancel")));
        address  seller  = Tracking[_Tracking].seller ;
        uint  Price  = Tracking[_Tracking].Price ;
        uint  token  = Tracking[_Tracking].tokenID ;
        address  bidder  = Tracking[_Tracking].bidder ;
        Tracking[_Tracking].cancel = cancel; 
                 if(bidder!=address(0)){
                 erc20.transfer(bidder,Price);
               // result[0] = "Reverted Amount to bidder";
                  }if(seller!=address(0)){
                e115.safeTransferFrom(address(this),seller,token,1,"0x"); 
              //  result[1] = "Reverted Amount to Seller";
                  }

                  return true;
    }

     //Bidder send amount in erc20(Snc) to escrow address with certain time
     function  Bidder(address payable _bidder, uint _Price , string memory _Tracking ,uint _bidderdeadline ) external  returns(bool){
    require(bytes(_Tracking).length != 0, "Tracking should not be empty");
      require(_bidder != address(0),"Bidder address should not be empty");
      require(_Price != 0,"Price  is empty");
       require(_bidderdeadline != 0,"bidderdeadline should not be  empty");

          Offer memory  val = Tracking[_Tracking];
        address  PreviousBidder = val.bidder;
        uint Previousamount = val.Price;
       
      //We are checking he is first bidder
        if(PreviousBidder == address(0)){
              
        //require(Price >=  BidAmountFromOffering, "Bidder Amount is less then Offering Price");
      Tracking[_Tracking].bidder = _bidder;
      Tracking[_Tracking].Price = _Price;
      Tracking[_Tracking].bidderConfirmed = true;
      Tracking[_Tracking].bidderdeadline = _bidderdeadline;
      erc20.transferFrom(_bidder, address(this), _Price);

        }else{
            if(address(PreviousBidder) == address(_bidder)){
              erc20.transferFrom(_bidder, address(this), _Price); 
            }else{
            require(_Price >  Previousamount, "Current Bidder Amount is less then Previous Bidder");
            //trasnfer BidAmount from Escrow address contract to Previous Bidder
              erc20.transfer(PreviousBidder,Previousamount);
              // result[0]= "Reverted Amount to previous Bidder";

              Tracking[_Tracking].bidder = _bidder;
              Tracking[_Tracking].Price = _Price;
              Tracking[_Tracking].bidderConfirmed = true;
             Tracking[_Tracking].bidderdeadline = _bidderdeadline;
    
                  erc20.transferFrom(_bidder, address(this), _Price);
             // result[1]= "Bidder has transfered amount"

            }
           
      }
       return true;
     }


     //If bidder given  timer has expired Send Erc20(SNC)oken amount back to bidder
      function EscrowAgentforBidder(string memory  _Tracking) external  returns(string memory reverted){
        require(bytes(_Tracking).length != 0, "Tracking should not be empty");
        address bidder =  Tracking[_Tracking].bidder;
        uint price = Tracking[_Tracking].Price ;

        uint biddertimer = Tracking[_Tracking].bidderdeadline;
       if(block.timestamp>= biddertimer){
        if(bidder!=address(0)){
            erc20.transfer(bidder,price);
                reverted = "Reverted Amount to Bidder.";
        }else{
                 reverted = "No Bidder Address in this Track.";  
        }
       
}
       return reverted;

      }



      //Send NFT to that particular bidder address which seller has choosen and amount to seller
      function EscrowAgentforSellerAcceptedBid(string memory _Tracking)external  returns(bool){
      require(bytes(_Tracking).length != 0, "Tracking should not be empty");
      address bidder =  Tracking[_Tracking].bidder;
      uint price = Tracking[_Tracking].Price;
      address  seller  = Tracking[_Tracking].seller ;
       uint  token  = Tracking[_Tracking].tokenID ;
       if(seller!=address(0)){
           erc20.transfer(seller,price);
               // result[0]= "Amount Sent to Seller.";
        }
         if(bidder!=address(0)){
           e115.safeTransferFrom(address(this),bidder,token,1,"0x");
                //result[1]= "Token sent  to bidder";
        }
         return true;
      }


     //If Seller given  timer has expired Send Erc20(SNC)oken  amount back to bidder and NFT to Seller
      function EscrowAgentforSellerTimer(string memory  _Tracking) external  returns(bool){
          require(bytes(_Tracking).length != 0, "Tracking should not be empty");
        address bidder =  Tracking[_Tracking].bidder;
        uint price = Tracking[_Tracking].Price ;
         address  seller  = Tracking[_Tracking].seller ;
        uint SellerTimer = Tracking[_Tracking].Sellerdeadline;
         uint  token  = Tracking[_Tracking].tokenID ;
      if( block.timestamp>=SellerTimer){
       if(bidder!=address(0)){
            erc20.transfer(bidder,price);
               // reverted = "Reverted Amount to Bidder.";
            }
        if(seller!=address(0)){
           e115.safeTransferFrom(address(this),seller,token,1,"0x");
                // reverted = "Reverted NFT to Seller";  
        }
       
}
       return true;

      }
}