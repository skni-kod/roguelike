module.exports = {
  productionSourceMap: false,
  chainWebpack(config) {
    config.plugins.delete("prefetch");
  },
  configureWebpack: (config) => {
    if (process.env.NODE_ENV === "production") {
      // production options
    } else {
      devtool: "source-map";
    }
  },
};
