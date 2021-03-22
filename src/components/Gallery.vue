<template>
  <div>
    <b-row no-gutters align-h="center" class="px-5 gallery" @click="show">
      <b-col cols="12" lg="4" class="p-2">
        <b-img src="../assets/scrin1.png" center fluid ></b-img>
      </b-col>
      <b-col cols="12" lg="4" class="p-2">
        <b-img src="../assets/scrin2.png" center fluid></b-img>
      </b-col>
      <b-col cols="12" lg="4" class="p-2">
        <b-img src="../assets/roguelike.png" center fluid></b-img>
      </b-col>
    </b-row>
    <div class="modal-img" v-bind:style="{display: display}">
      <img v-bind:src="src" alt="" />
      <span @click="close">&#10005;</span>
    </div>
  </div>
</template>

<script lang="ts">
import { Component } from "vue-property-decorator";
import Vue from "vue";
@Component({})
export default class Navbar extends Vue {
  public show(event:Event) {
    this.$data.display = 'flex';
    this.$data.src = String(event.target.src)
  }
  public close(event:Event) {
    this.$data.display = 'none';
    this.$data.src = ''
  }
  data(){
    return{
      display:'none',
      src:''
    }
  }
}
</script>

<style scoped>
.gallery > div > img {
  position: relative;
}
.gallery > div > img:hover {
  transform: scale(1.1);
  z-index: 1;
  transition: 0.3s;
  cursor: pointer;
}
.modal-img {
  width: 100vw;
  height: 100vh;
  position: fixed;
  top: 0;
  left: 0;
  z-index: 9;
  background: RGB(0, 0, 0, 0.7);
  justify-content: center;
  align-items: center;
}
.modal-img > img {
  max-width: 80vw;
  height: auto;
}
.modal-img > span {
  font-size: 40px;
  font-weight: bolder;
  cursor: pointer;
  position: absolute;
  top: 30px;
  right: 60px;
  color: white;
}
</style>