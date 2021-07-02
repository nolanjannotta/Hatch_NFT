This contract allows users to mint NFTs with a random incubation period, and then hatch them after the period is over. The deployer can set a range in
minutes for the incubation period when deploying the contract. Then, using the chainlink VRF, a random number is generated when a user mints an NFT. The number 
randomly chooses an amount of minutes within the range. The initial URI is set to "incubating", and can't be changed during the time period. After the 
incubation period, the NFT owner can call the HatchNft function which uses another random number to pick a random creature URI, thus "hatching" your NFT. 

TODO:
[] experiment with chainlink Keepers to automatically hatch the NFT.
[] experiment with Gelato for the same thing
[] add flexibilty for the incubation period (hours or days)
[] clean up code
[] write tests
[] create simple front end
