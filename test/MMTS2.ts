import {BigNumber, Contract, ethers, utils} from 'ethers';
import {config,Token} from "./config2";

declare const ethereum: any;



function checknetwork(params: any){
  return function(target: any, methodName: any, desc: any){
  
    let oldMethod = desc.value;
    desc.value = async function(...args: any[]){
      const chainId: any = await ethereum.request({
        method: 'eth_chainId'
      });
      const CHAINID_STR: string = '0x' + params.toString(16);
      if (CHAINID_STR != chainId) {
        console.log('Please switch to ' + config.ChainName + ' network!');
        try {
          await ethereum.request({
            method: 'wallet_switchEthereumChain',
            params: [{chainId: CHAINID_STR}],
          });
          return oldMethod.apply(this, args);
        } catch (err) {
          return err;
        }
      } else {
        return oldMethod.apply(this, args);
      }
    };
  };
}

function isMetamask(){
  return function(target: any, methodName: any, desc: any){
    var oldMethod = desc.value;
    var isPass = true;
    desc.value = async function(...args: any[]){
      if (typeof ethereum == 'undefined') {
        const err: any = {
          message: ' Plaese install Metamask',
          code: 'cus_10001'
        };
        return err;
      }
      return oldMethod.apply(this, args);
    };
  };
}

export class MM {
  provider: any;
  signer: any;
  defaultAccount: any = null;
  limit: string = '115792089237316195423570985008687907853269984665640564039457584007913129639935';
  contracts: Map<string, any> = new Map<string, any>();
  MechHeroList: any = []
  ABI: any = {};
  constructor(){}

  @isMetamask() @checknetwork(config.ChainId)
  async initApp(connectWalconstNow: Boolean): Promise<any>{
    try {
      const that = this;
      that.provider = new ethers.providers.Web3Provider((window as any).ethereum);
      that.signer = this.provider.getSigner();
      ethereum.on('accountChanged', (chainId: any) => {
        window.location.reload();
      });
      if (connectWalconstNow) {
        await that.connectWallet();
      }
      return {
        isOk: true,
        msg: 'Browser environment detected as normal'
      };
    } catch (err) {
      return err;
    }
  };

  @isMetamask() @checknetwork(config.ChainId)
  async connectWallet(){
    const that = this;
    try {
      const accounts = await ethereum.request({method: 'eth_requestAccounts'});
      window.sessionStorage.setItem('connectWalletNow', 'true');
      that.defaultAccount = accounts[0];
      ethereum.on('accountsChanged', function(accounts: any){
        that.defaultAccount = accounts[0];
        window.location.reload();
      });
      ethereum.on('chainChanged', function(res: any){
        console.log(res)
      });
      await this.initABI();
      return {
        isOk: true,
        msg: 'Walconst link successful'
      };
    } catch (e) {
      return e;
    }
  };
  async SignFn(){
   return await this.signer.signMessage('ligin this website')
  }
  
  async checkBrowser(){
    if (typeof ethereum == 'undefined') {
      const err: any = {
        isOk: false,
        msg: 'Plaese install Metamask'
      };
      return err;
    }else{
      return {
        isOk: true,
        msg: 'Browser environment detected as normal'
      }
    }
  };
  
  async checkNetwork(){
    const chainId: any = await ethereum.request({
      method: 'eth_chainId'
    });
    const CHAINID_STR: string = config.ChainId;
    if (CHAINID_STR != chainId) {
      return {
        isOk: false,
        msg: 'Please switch to ' + config.ChainName + ' network!'
      }
    } else {
      return {
        isOk: true,
        msg: 'successful'
      }
    }
  };
  
  private async initABI(){
    const abis = [
      'MMTRADING'
    ]
    for (const abi of abis) {
      try {
        this.ABI[abi] = require(`./abis/${abi}.json`).abi;
      }catch (err){
      }
    }
    console.log(this.ABI)
  };

  

 
  async getBalance(TokenName:string){
    const that = this;
    const ERC20Contract = new Contract(
      config[TokenName],
      config.ERC20ABI,
      that.signer);
    console.log(ERC20Contract)
    let balacne = await ERC20Contract['balanceOf'](that.defaultAccount);
    console.log(balacne)
    let num = utils.formatUnits(balacne,18)
    return num;
  }
 
  async CheckApprove(TokenName:string): Promise<any>{
    const that = this;
    const ERC20Contract = new Contract(
      config[TokenName],
      config.ERC20ABI,
      that.signer);
    let isApprove: boolean = false;
    try {
      await ERC20Contract.allowance(
        that.defaultAccount,
        config[TokenName+'_TRADING'].addr
      ).then((res: any) => {
        const amount = BigNumber.from('11111111111111000000000000000000');
        if (BigNumber.from(res.toString()).gt(amount)) {
          isApprove = true;
        } else {
          isApprove = false;
        }
      });
      return {
        isOk: isApprove ? true : false,
        msg: isApprove ? 'success' : 'error: Insufficient authorized amount'
      };
    } catch (err) {
      return err;
    }
  };
 
  async Approve(TokenName:string,amount?: any): Promise<any>{
    const that = this;
    let TokenStr = ''
    console.log( config[TokenName])
    const ERC20Contract = new Contract(
      config[TokenName],
      config.ERC20ABI,
      that.signer
    );
    try {
      let min: any = 0;
      if (amount == 0) {
        min = amount;
      } else {
        min = that.limit;
      }
      console.log( config[TokenName+'_TRADING'].addr)
      const res: any = await ERC20Contract['approve'](
        config[TokenName+'_TRADING'].addr,
        min
      );
      const result = await res.wait();
      console.log(result)
      return {
        isOk: true,
        msg: 'success'
      };
    } catch (err) {
      console.log(err);
      return err;
    }
  };

  
  

  private async CheckApproveNFT(Name:string): Promise<any>{
    const that = this;
    const ERC721Contract = new Contract(
      config[Name],
      config.ERC721ABI,
      that.signer);
    let isApprove: boolean = false;
    try {

      console.log(config[Name+'_TRADING'].addr);
      await ERC721Contract.isApprovedForAll(
        that.defaultAccount,
        config[Name+'_TRADING'].addr
      ).then((res: any) => {
          isApprove = res;
      });
      return isApprove
    } catch (err) {
      console.log(err)
      return false;
    }
  }
  async withdrawProps(arg:any){
    let {signature,time,PropsName, Amount}:any = arg;
    if (Amount<= 0 || Amount > 5){
      return {
        isOk: false,
        msg: "Please fill in 1～5"
      }
    }
    const That = this;
    try {
      let PropsContract = new Contract(
        config.PROPS_TRADING.addr,
        config.PROPS_TRADING.abi,
        this.signer
      )
      let res = await PropsContract['withdraw'](
        That.defaultAccount,
        config[PropsName],
        Amount,
        time,
        signature
      );
      await res.wait();
      return {
        isOk: true,
        msg: 'success'
      };
    }catch (err:any){
      return {
        isOk: false,
        msg: err.message  || err.error.message
      };
    }
  }
  
  
  
  
}
