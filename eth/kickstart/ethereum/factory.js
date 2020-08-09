import web3 from './web3';
import CampaignFactory from './build/CampaignFactory.json'

const instance = new web3.eth.Contract(
  JSON.parse(CampaignFactory.interface),
  '0x04Ef053C0ABBFBCe65Df1612E2E3E9A4e8A76e7A'
);

export default instance;
