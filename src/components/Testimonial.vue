<template>
  <div class="testimonial-bg">
    <div
      v-for="testimonial in testimonials"
      :key="testimonial.img"
      style="
        display: flex;
        justify-content: center;
        align-items: center;
        flex-direction: column;
      "
    >
      <b-img :src="require(`@/assets/${testimonial.img}`)"></b-img>
      <h3 style="color: white" class='text-center'>{{ testimonial.name }}</h3>
      <h5 style="color: white" v-for="role in testimonial.role" :key="role">
        {{ role }}
      </h5>
      <span
        style="
          font-size: 30px;
          display: flex;
          justify-content: space-around;
          align-items: center;
          width: 50%;
          color: white;
        "
      >
        <b-icon
          v-for="icon in testimonial.icons"
          :key="icon.name"
          :icon="icon.name"
          @click="window.location.href = icon.link"
          style="cursor: pointer"
        ></b-icon>
      </span>
    </div>
  </div>
</template>

<script lang='ts'>
import { Component, Prop, Vue } from "vue-property-decorator";
@Component({
  components: {},
})
export default class App extends Vue {
  @Prop({ required: true }) public testimonials!: object;
  get Testimonials() {
    return this.testimonials;
  }
  data() {
    return {
      window: window,
    };
  }
}
</script>

<style scoped>
.testimonial-bg {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  background: grey;
  padding: 50px;
  width: 360px;
  height: 360px;
  border-radius: 10%;
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
img {
  width: auto;
  height: 180px;
  border-radius: 50%;
}
</style>