import Web3 from 'web3';

let web3;

if (typeof window !== 'undefined' && typeof window.web3 !== 'undefined') {
  window.web3.currentProvider.enable();
  web3 = new Web3(window.web3.currentProvider);
} else {
  const provider = new Web3.providers.HttpProvider(
    'https://rinkeby.infura.io/v3/672e5c94db4741fca17d2c6991dfa596'
  );
  web3 = new Web3(provider);
}

export default web3;