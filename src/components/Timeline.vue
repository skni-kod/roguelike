<template>
  <div class="timeline">
    <ul>
      <li v-for="timePoint in timePoints" :key="timePoint.name">
        <div style='color:white'>{{ timePoint.name }}</div>
      </li>
    </ul>
  </div>
</template>
<script lang="ts">
import { Component, Prop } from "vue-property-decorator";
import Vue from "vue";
@Component({})
export default class Timeline extends Vue {
  @Prop({ required: true }) public timePoints!: object;
}
</script>
<style scoped>
.timeline ul {
  padding: 10px;
}

.timeline ul li {
  list-style-type: none;
  position: relative;
  width: 6px;
  margin: 0 auto;
  padding-top: 50px;
  background: #fff;
}

.timeline ul li:first-child::after {
  content: "";
  position: absolute;
  left: 50%;
  bottom: 0;
  transform: translateX(-50%);
  width: 30px;
  height: 30px;
  border-radius: 50%;
  background: inherit;
}

.timeline ul li::after {
  content: "";
  position: absolute;
  left: 50%;
  top: calc(50% + 9px);
  background: rgb(84,19,19);
  border: 5px white solid;
  transform: translateX(-50%);
  width: 30px;
  height: 30px;
  border-radius: 50%;
}

.timeline ul li div {
  position: relative;
  bottom: 0;
  padding: 15px;
  background: #17a2b8;
  width: 150px;
  font-weight: bold;
  border-radius: 20%;
    text-align: center;
}

.timeline ul li div::before {
  content: "";
  position: absolute;
  top: calc(50% - 8px);
  width: 0;
  height: 0;
  border-style: solid;
}

.timeline ul li:nth-child(odd) div {
  left: 45px;
}

.timeline ul li:nth-child(odd) div::before {
  left: -15px;
  border-width: 8px 16px 8px 0;
  border-color: transparent #17a2b8 transparent transparent;
}

.timeline ul li:nth-child(even) div {
  left: -190px;
}

.timeline ul li:nth-child(even) div::before {
  right: -15px;
  border-width: 8px 0 8px 16px;
  border-color: transparent transparent transparent #17a2b8;
}

time {
  display: block;
  font-size: 1.2rem;
  font-weight: bold;
  margin-bottom: 8px;
}

/* GENERAL MEDIA QUERIES
–––––––––––––––––––––––––––––––––––––––––––––––––– */

@media screen and (max-width: 900px) {
  .timeline ul li div {
    width: 250px;
  }
  .timeline ul li:nth-child(even) div {
    left: -289px;
    /*250+45-6*/
  }
}

@media screen and (max-width: 600px) {
  .timeline ul li {
    margin-left: 20px;
  }
  .timeline ul li div {
    width: calc(100vw - 150px);
  }
  .timeline ul li:nth-child(even) div {
    left: 45px;
  }
  .timeline ul li:nth-child(even) div::before {
    left: -15px;
    border-width: 8px 16px 8px 0;
    border-color: transparent #17a2b8 transparent transparent;
  }
}
</style>