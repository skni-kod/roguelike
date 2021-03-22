<template>
  <div>
    <div class="background"></div>
    <b-row no-gutters align-h="center" class="mt-5">
      <b-col
        cols="10"
        lg="4"
        style="display: flex; justify-content: center; align-items: center"
      >
        <testimonial
          style="border-radius: 50%"
          class="skni"
          :testimonials="[
            {
              img: 'skni.png',
              name: '',
              role: [''],
              icons: [
                { name: 'facebook', link: 'https://www.facebook.com/skni.kod' },
                { name: 'globe2', link: 'https://kod.prz.edu.pl/#/' },
              ],
            },
          ]"
        ></testimonial>
      </b-col>
      <b-col lg="6" cols="11">
        <newslist
          :news="[
            {
              title: 'O nas',
              description: `
                <p>Jesteśmy członkami Studenckiego Koła Naukowego KOD założonego w 1997 roku, skupiającego studentów Politechniki Rzeszowskiej imienia Ignacego Łukasiewicza.</p>
                <p>Łączy nas pasja i chęć rozwoju. Projekt wystartował w grudniu 2020 roku a po 4 miesiącach możemy zaprezentować pierwszą grywalną wersję.</p>
                <p>Nasze technologie:</p>
                <ul style='list-style:none'>
                  <li>Godot</li>
                  <li>GDScript</li>
                </ul>
`,
              time: '',
            },
          ]"
        ></newslist>
      </b-col>
    </b-row>
    <b-row no-gutters align-h="center" class="py-5">
      <b-col
        cols="10"
        style="display: flex; justify-content: center; align-items: center"
        class="mt-3"
        v-for="testimonial in testimonials"
        :key="testimonial.img"
        lg="4"
        xl="3"
        md="5"
      >
        <testimonial :testimonials="testimonial"></testimonial>
      </b-col>
    </b-row>
  </div>
</template>
<script lang='ts'>
import { Component, Prop, Vue } from "vue-property-decorator";
@Component({
  components: {},
})
export default class App extends Vue {
  data() {
    return {
      window: window,
      testimonials: [
        [
          {
            img: "Kacper Maciolek.png",
            name: "Kacper Maciołek",
            role: ["Project Leader", "Programista"],
            icons: [
              { name: "github", link: "https://github.com/Kacperacy" },
              {
                name: "linkedin",
                link: "https://www.linkedin.com/in/kacper-maciołek-577564209/",
              },
            ],
          },
        ],
        [
          {
            img: "Adrian Malec.jpg",
            name: "Adrian Malec",
            role: ["Programista", "Web Developer"],
            icons: [
              { name: "github", link: "https://github.com/f10k1" },
              {
                name: "linkedin",
                link: "https://www.linkedin.com/in/adrian-malec-a252321a1/",
              },
            ],
          },
        ],
        [
          {
            img: "Rafal Gawel.png",
            name: "Rafał Gaweł",
            role: ["Programista"],
            icons: [{ name: "github", link: "https://github.com/Smok7kp" }],
          },
        ],
        [
          {
            img: "Hubert Augustyn.png",
            name: "Hubert Augustyn",
            role: ["Programista"],
            icons: [{ name: "github", link: "https://github.com/Keerch" }],
          },
        ],
        [
          {
            img: "Artur Szalyga.png",
            name: "Artur Szałyga",
            role: ["Programista", "Grafik"],
            icons: [{ name: "github", link: "https://github.com/WolfArt" }],
          },
        ],
        [
          {
            img: "Maciek Pietrasz.jpg",
            name: "Maciek Pietrasz",
            role: ["Grafik"],
            icons: [{ name: "github", link: "https://github.com/Komosabe" }],
          },
        ],
        [
          {
            img: "Remigiusz Sieczkowski.png",
            name: "Remigiusz Sieczkowski",
            role: ["Programista"],
            icons: [
              { name: "github", link: "https://github.com/Mixu285" },
              {
                name: "linkedin",
                link:
                  "https://www.linkedin.com/in/remigiusz-sieczkowski-51666b209/",
              },
            ],
          },
        ],
        [
          {
            img: "Maksymilian Dendura.png",
            name: "Maksymilian Dendura",
            role: ["Programista"],
            icons: [{ name: "github", link: "https://github.com/Noniv" }],
          },
        ],
        [
          {
            img: "Marcin Bandos.png",
            name: "Marcin Bandos",
            role: ["Programista"],
            icons: [{ name: "github", link: "https://github.com/marycin" }],
          },
        ],
        [
          {
            img: "Radzio17.png",
            name: "Radzio17",
            role: ["Programista"],
          },
        ],
        [
          {
            img: "Michal Basznianin.png",
            name: "Michał Basznianin",
            role: ["Programista"],
          },
        ],
        [
          {
            img: "Jerzy Baran.png",
            name: "Jerzy Baran",
            role: ["Dźwiękowiec", "Programista"],
            icons: [{ name: "github", link: "https://github.com/Jaykes22" }],
          },
        ],
        [
          {
            img: "Grzegorz Zieba.jpg",
            name: "Grzegorz Zięba",
            role: ["Dźwiękowiec"],
            icons: [{ name: "github", link: "https://github.com/Jaykes22" }],
          },
        ],
        [
          {
            img: "Kacper Fila.png",
            name: "Kacper Fila",
            role: ["Programista"],
            icons: [{ name: "github", link: "https://github.com/KacperFila" }],
          },
        ],
        [
          {
            img: "placeholder.png",
            name: "Arek Strugała",
            role: ["Programista"],
            icons: [{ name: "github", link: "https://github.com/Arox919" }],
          },
        ],
        [
          {
            img: "placeholder.png",
            name: "Dawid Pindara",
            role: ["Programista"],
            icons: [{}],
          },
        ],
      ],
    };
  }
}
</script>
<style scoped>
.background {
  background: url("../assets/tlo_download.png");
  background-repeat: no-repeat;
  background-size: cover;
  position: fixed;
  width: 100vw;
  height: 100vh;
  margin: 0;
  top: 0;
  left: 0;
  z-index: -1;
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