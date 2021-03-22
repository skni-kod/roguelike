<template>
  <div id="app">
    <Loading />
    <Navbar />
    <router-view :key="$route.fullPath" />
    <Footer />
  </div>
</template>

<script lang='ts'>
import Vue from "vue";
import { Component } from "vue-property-decorator";

import Loading from "@/components/Loading.vue";
import Navbar from "@/components/Navbar.vue";
import Footer from "@/components/Footer.vue";
import { BootstrapVue, BootstrapVueIcons } from "bootstrap-vue";

Vue.use(BootstrapVue);
Vue.use(BootstrapVueIcons);
@Component({
  components: { Navbar, Footer, Loading },
})
export default class App extends Vue {}
</script>
<style lang="scss">
@import "~bootstrap/scss/bootstrap.scss";
@import "~bootstrap-vue/src/index.scss";

.skni > div > img {
  border-radius: 0%;
}
</style>
<style>
@font-face {
  font-family: "Impostor";
  src: local("Impostor"), url("./fonts/The Impostor.ttf") format("truetype");
}
</style>
