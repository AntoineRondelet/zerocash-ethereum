module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*",
      gasprice: 0x1
    },
  },
  solc: {
    optimizer: {
      enabled: true,
        runs: 200
    }
  }
};
