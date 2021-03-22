<template>
  <div>
    <b-card
      class="text-center mx-xl-5 card-bg"
      text-variant="white"
      style="
        -webkit-box-shadow: 0px 0px 19px 5px rgba(0, 0, 0, 0.37);
        box-shadow: 0px 0px 19px 5px rgba(0, 0, 0, 0.37);
      "
      v-for="info in news"
      :key="info.title"
    >
      <b-row>
        <b-col>
          <h5
            class="text-left pl-xl-4"
            style="
              font-family: 'Impostor', Helvetica, Arial;
              font-family: 'Impostor', Helvetica, Arial;
              -webkit-text-stroke: 3px black;
              -webkit-text-fill-color: white;
            "
          >
            {{ info.title }}
          </h5></b-col
        >
        <b-col style="font-weight: lighter" class="text-right pr-xl-5">{{
          info.time
        }}</b-col>
      </b-row>

      <b-dropdown-divider style="list-style: none"></b-dropdown-divider>
      <b-card-text class="px-xl-4 text-left" v-html="info.description"></b-card-text>
    </b-card>
  </div>
</template>

<script lang="ts">
import { Component, Prop, Vue } from "vue-property-decorator";
@Component
export default class Newslist extends Vue {
  @Prop({ required: true }) public news!: object;
  get News() {
    return this.news;
  }
}
</script>

<style scoped>
p {
  text-align: justify;
}
.card-bg {
  background: rgb(128, 30, 30);
  background: -moz-linear-gradient(
    180deg,
    rgba(128, 30, 30, 1) 0%,
    rgba(106, 24, 24, 1) 50%,
    rgba(84, 19, 19, 1) 100%
  );
  background: -webkit-linear-gradient(
    180deg,
    rgba(128, 30, 30, 0.5) 0%,
    rgba(106, 24, 24, 0.5) 50%,
    rgba(84, 19, 19, 0.5) 100%
  );
  background: linear-gradient(
    180deg,
    rgba(128, 30, 30, 0.7) 0%,
    rgba(106, 24, 24, 0.7) 50%,
    rgba(84, 19, 19, 0.7) 100%
  );
  filter: progid:DXImageTransform.Microsoft.gradient(startColorstr="#801e1e",endColorstr="#541313",GradientType=1);
}
</style>