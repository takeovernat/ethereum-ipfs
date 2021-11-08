// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * Natnael Teshome
 * Vshare
 */
 //V
 
 /* alternative gas saving struct for ipfs hash, not used in version 1*/
    struct Multihash {
        bytes32 hash;
        uint8 hash_function;
        uint8 size;
        }
 /*struct for assets, currenly not being used for version 1*/        
    struct Asset{
        uint256 asset_type;
        uint256 asset_id;
        Multihash hashSt;
        uint256 userId;
    }
/*struct for requests used in requestes of assets*/    
    struct Request{
        address Requester;
        uint RequestedDataType;
    }

 contract Vshare{
     
     uint256 userCount; //keeps count of total Users
     uint256 totalAssetsCount; //keeps count of total assets added
     uint256 totalShares; //keeps track of total shares and allows
     
     mapping (uint256 => address) users; //holds user id for registration purposes
     mapping (address => uint256) reverseId; //gives me ability to find id by address
     //mapping (address => Asset[]) assets_owned;
     mapping (address => string[]) assets_owned; //maps user to string array
     mapping (uint256 => Request[]) requests; //maps user ids to request array
     mapping (address => uint256) requestCount; //counts how many requets a user has
     mapping (address => uint256) assetCount; //counts how many assets a user has
     
    //constructor initiates some thangs    
     constructor() {
        userCount = 1;
        totalAssetsCount = 0;
        totalShares = 0;
    }
   
    //returns request count
    function GetRequestCount() public view returns(uint256){
        require(reverseId[msg.sender] != 0, "you must register first");
        return requestCount[msg.sender];
   
    }
    //returns asset count
    function GetAssetCount() public view returns(uint256){
        require(reverseId[msg.sender] != 0, "you must register first");
        return assetCount[msg.sender];
    }
   
    //returns total user count
    function GetUserCount() private view returns(uint256){
        require(reverseId[msg.sender] != 0, "you must register first");
        return userCount-1;
    }
    //returns registred users' id
    function GetUserId() public view returns (uint256){
       
        require(reverseId[msg.sender] != 0, "you must register first");
        return reverseId[msg.sender];
    }

    //users can register
    function RegisterUser() public {
        users[userCount] = msg.sender;
        reverseId[msg.sender] = userCount;
        userCount++;
    }

    //list the requets that you have
    function ListRequests() public view returns(Request[] memory) {
       
        if(reverseId[msg.sender] == 0){
            revert("user must be registred");
        }
        uint256 userid = reverseId[msg.sender];
        Request[] memory reqs = requests[userid];
        if(reqs.length == 0){
            revert("no requests available");
        }
       return reqs;
        }
       //function for adding assets, uses strings for now
    function AddAsset(string memory hash) public{
       
       if(reverseId[msg.sender] == 0){
            revert("user must be registred");
            }
       
       assets_owned[msg.sender].push(hash);
       string[] memory T = assets_owned[msg.sender];
            assetCount[msg.sender] = T.length;
            totalAssetsCount++;
        }
   /*function to allow registred users to request asset
   from another using some identification value for the asset*/
    function RequestAsset(uint256 userId, uint256 asset_type) public {
       require(userId != 0 && userId < userCount, ("invalid user id"));
       require(users[userId]!= address(0), ("user is not registred, please register your address"));
       require(reverseId[msg.sender] != 0, "you must register first");
       address RequestAddress = users[userId];
       require(userId != reverseId[msg.sender], ("you cannnot request your own asset!"));
       Request memory req;
       req.Requester = msg.sender;
       req.RequestedDataType = asset_type;
       requests[userId].push(req);
       requestCount[RequestAddress] += 1;
     
       }

   //event that emits when an asset is shared
     event assetShared(address from, address to, uint256 asset_type);
/*
function that gives access to specific asset type to other users
*/
    function AllowAccess(uint256 asset_type, uint256 userId) public { //assetid
        require(userId != 0 && userId < userCount, ("invalid user id"));
        require(users[userId]!= address(0), ("user is not registred, please register your address"));
        require(reverseId[msg.sender] != 0, "you must register first");
        require(userId != reverseId[msg.sender], ("you cannnot request your own asset!"));
        address AllowAddress = users[userId];
        string[] memory assets = assets_owned[msg.sender];
        if(assets.length == 0){
            revert("you have no assets to share");
        }
    //send first asset but later we will have a condition on which lets user select specific
        assets_owned[AllowAddress].push(assets[0]);
        totalShares++;
        assetCount[AllowAddress] += 1;
        emit assetShared(msg.sender, AllowAddress, asset_type);
   
    }
   /*
   function that returns all assets in an array
   I */
    function ListAssets() public view returns(string[] memory){
        require(reverseId[msg.sender] != 0, "you must register first");
        string[] memory Assets = assets_owned[msg.sender];
        if(Assets.length == 0){
            revert("you have no Assets");
        }
        return Assets;
    }
   
    /*
    function that allows users read assets based on asset type
    which is not being used in version 1
    */
    function ReadAsset(uint256 ownerid, uint256 asset_type) public view returns(string memory ){
        require(reverseId[msg.sender] != 0, "you must register first");
        require(ownerid != 0 && ownerid <= userCount);
        address assets_Owner_address = users[ownerid];
        string[]memory assets = assets_owned[msg.sender] ;
        require(assets.length != 0, ("you have no assets to read"));
        //emit Asset_Read(msg.sender, assets_Owner_address , asset_type);
        return assets[0];
        }
    }
