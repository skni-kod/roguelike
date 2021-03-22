<template>
  <div>
    <div class="background"></div>
    <b-row no-gutters class="p-5" align-h="between">
      <b-col cols="12" lg="12" xl="5" class="ml-lg-5">
        <b-row no-gutters align-h="center">
          <b-col cols="12" lg="9">
            <h4 style='color:white' class='text-center'>Wersja 0.0.2</h4>
            <b-progress
              height="30px"
              v-for="bar in bars"
              :key="bar.name"
              :max="bar.max"
              striped
              variant="info"
              class="mb-2"
              :value="bar.value"
            >
              <span
                style="
                  line-height: 30px;
                  text-align: center;
                  position: absolute;
                  width: 100%;
                "
                ><strong style="color: black"
                  >{{ bar.name }}: {{ bar.value }} / {{ bar.max }}</strong
                ></span
              >
              <b-progress-bar :value="bar.value"></b-progress-bar>
            </b-progress>
          </b-col>
          <b-col cols="12">
            <timeline :timePoints="timePoints"></timeline>
          </b-col>
        </b-row>
      </b-col>
      <b-col cols="12" lg="12" xl="6" class="pr-xl-3 mr-xl-3">
        <newslist :news="update"></newslist>
      </b-col>
    </b-row>
  </div>
</template>
<script lang="ts">
import Vue from "vue";
export default Vue.extend({
  data() {
    return {
      bars: [
        { name: "Programowanie", value: 80, max: 80 },
        { name: "Grafika", value: 30, max: 30 },
        { name: "Soundtrack", value: 10, max: 10 },
        { name: "Planowanie", value: 100, max: 100 },
        { name: "Usuwanie błędów", value: 7, max: 7 },
      ],
      timePoints: [
        { name: "Wersja 0.0.2" },
         { name: "Wersja 0.0.5" },
        { name: "Wersja 0.7" },
        { name: "Wersja 0.2" },
      ],
      update: [
        {
          title: "Wersja 0.0.2",
          time: "22.03.2021",
          description: `
          <p>Po 4 miesiącach prac nad projektem, w końcu możemy zaprezentować Wam pierwszą grywalną wersję gry.</p>
          <p>Aktualna wersja oferuje:</p>
          <ul style='list-style:none'>
          <li>postać rycerza</li>
          <li>proceduralnie generowane lochy</li>
          <li>8 różnorodnych broni</li>
          <li>9 przeciwników</li>
          <li>wymagającego bossa</li>
          <p><br></p>
          <a class='btn btn-danger' href='#'>Pobierz już teraz</a>
          `,
        },
      ],
    };
  },
});
</script>

<style scoped>
.background {
  background: url("../assets/tlo_download.png");
  background-repeat: no-repeat;
  background-size: cover;
  width: 100vw;
  height: 100vh;
  margin: 0;
  top: 0;
  left: 0;
  position: fixed;
}
</style>