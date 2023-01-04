// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract deTweet {
    struct tweet {
        uint256 nonce;
        string tweet;
        address creator;
        uint256 likes;
        uint256 dislikes;
    }

    mapping(uint256 => address) idToAddress;
    mapping(uint256 => uint256) nonceToId;
    mapping(uint256 => mapping(address => uint256)) nonceToAddressToStatus;
    // 0 = no reaction
    // 1 = like
    // 2 = dislike

    tweet[] s_posts;

    function postMsg(string memory _tweet) public {
        uint256 nonce = s_posts.length + 1;
        tweet memory newTweet = tweet(nonce, _tweet, msg.sender, 0, 0);
        s_posts.push(newTweet);
        idToAddress[s_posts.length - 1] = msg.sender;
        nonceToId[nonce] = s_posts.length - 1;
    }

    function likePost(uint256 nonce) public {
        require(nonceToAddressToStatus[nonce][msg.sender] != 1);
        if (nonceToAddressToStatus[nonce][msg.sender] == 2) {
            removeDislike(nonce);
        }
        uint256 _id = nonceToId[nonce];
        s_posts[_id].likes++;
        if (_id < s_posts.length - 1) {
            tweet memory temp = s_posts[_id + 1];
            s_posts[_id + 1] = s_posts[_id];
            s_posts[_id] = temp;
            nonceToId[nonce]++;
            nonceToId[s_posts[_id].nonce]--;
        }
        nonceToAddressToStatus[nonce][msg.sender] = 1;
    }

    function removeLike(uint256 nonce) public {
        require(nonceToAddressToStatus[nonce][msg.sender] == 1);
        uint256 _id = nonceToId[nonce];
        s_posts[_id].likes--;
        if (_id > 0) {
            tweet memory temp = s_posts[_id - 1];
            s_posts[_id - 1] = s_posts[_id];
            s_posts[_id] = temp;
            nonceToId[nonce]--;
            nonceToId[s_posts[_id].nonce]++;
        }
        nonceToAddressToStatus[nonce][msg.sender] = 0;
    }

    function dislikePost(uint256 nonce) public {
        require(nonceToAddressToStatus[nonce][msg.sender] != 2);
        if (nonceToAddressToStatus[nonce][msg.sender] == 1) {
            removeLike(nonce);
        }
        uint256 _id = nonceToId[nonce];
        s_posts[_id].dislikes++;
        if (_id > 0) {
            tweet memory temp = s_posts[_id - 1];
            s_posts[_id - 1] = s_posts[_id];
            s_posts[_id] = temp;
            nonceToId[nonce]--;
            nonceToId[s_posts[_id].nonce]++;
        }
        nonceToAddressToStatus[nonce][msg.sender] = 2;
    }

    function removeDislike(uint256 nonce) public {
        require(nonceToAddressToStatus[nonce][msg.sender] == 2);
        uint256 _id = nonceToId[nonce];
        s_posts[_id].dislikes--;
        if (_id < s_posts.length - 1) {
            tweet memory temp = s_posts[_id + 1];
            s_posts[_id + 1] = s_posts[_id];
            s_posts[_id] = temp;
            nonceToId[nonce]++;
            nonceToId[s_posts[_id].nonce]--;
        }
        nonceToAddressToStatus[nonce][msg.sender] = 0;
    }

    function getNumPost() public view returns (uint256) {
        return s_posts.length;
    }

    function getLikes(uint256 nonce) public view returns (uint256) {
        return s_posts[nonceToId[nonce]].likes;
    }

    function getDislikes(uint256 nonce) public view returns (uint256) {
        return s_posts[nonceToId[nonce]].dislikes;
    }

    function getCreator(uint256 nonce) public view returns (address) {
        return s_posts[nonceToId[nonce]].creator;
    }

    function getPostFromNonce(uint256 nonce)
        public
        view
        returns (string memory)
    {
        return s_posts[nonceToId[nonce]].tweet;
    }

    function getPostFromId(uint256 _id) public view returns (string memory) {
        return s_posts[_id].tweet;
    }
}
