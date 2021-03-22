<template>
  <b-navbar fixed="bottom">
      <b-col cols="12" align="center">
        <b-navbar-brand style='font-size:14px;' class='text-light'>Wszelkie prawa zastrzeżone &copy;</b-navbar-brand>
      </b-col>
  </b-navbar>
</template>

<script lang="ts">
import { Component, Prop, Vue } from "vue-property-decorator";

@Component
export default class Footer extends Vue {}
</script>
