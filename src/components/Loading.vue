<template>
  <div v-bind:style='"display:"+display'>
    <img src="../assets/loading.gif" v-bind:style='"display:"+display' />
  </div>
</template>

<script lang='ts'>
import Vue from "vue";
import { Component } from "vue-property-decorator";
@Component({})
export default class Loading extends Vue {
    
    timeout = setTimeout(this.Hide, 2000) as unknown as number;

    private Hide(){
        this.$data.display = 'none'
    }

    data(){
        return{
            display:'flex',
        }
    }
}
</script>

<style scoped>
div {
  position: fixed;
  height: 100vh;
  width: 100vw;
  justify-content: center;
  align-items: center;
  background: RGB(84, 30, 30, 0.9);
  z-index: 999;
}
</style>