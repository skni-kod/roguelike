<template>
  <div>
    <div class="background"></div>
    <b-row class="wrapper" no-gutters>
      <video
        class="bg-vid"
        autoplay
        muted
        loop
        type="video/mp4"
        src="../assets/Roguelike_demo.mp4"
      ></video>
      <div class="gradient"></div>
    </b-row>
    <b-row no-gutters class="text-light a" align-h="center" align-v="center">
      <b-col cols="12"
        ><b-img src="../assets/kokarda.png" center fluid class="kokarda"></b-img
      ></b-col>
      <b-col
        cols="12"
        md="6"
        lg="4"
        order-md="2"
        order="1"
        class="pb-5 text-center"
      >
        <h3
          style="
            font-family: 'Impostor', Helvetica, Arial;
            -webkit-text-stroke: 3px black;
            -webkit-text-fill-color: white;
          "
        >
          Wkrocz do Swiata Roguelike!
        </h3>
        <span>
          Roguelike to wyjątkowa przygoda podczas której spotkasz wielu
          unikatowych NPC, którzy będą niezbędni do rozwoju postaci!<br />
          Walcz z wieloma przeciwnikami i bossami którzy potrafią napsuć sporo
          krwi.<br />
          Zbieraj pieniądze i materiały które pomogą ci rozwinąć postać i
          posiadłość.<br />
          Walcz postacią którą chcesz oferujemy wiele różnorodnych postaci - od
          rycerza przez barbażyńcę po maga!<br /><br />
          <h4
            style="
              font-family: 'Impostor', Helvetica, Arial;
              -webkit-text-stroke: 3px black;
              -webkit-text-fill-color: white;
            "
          >
            Roguelike to:
          </h4>
          <b-row align-v="center" no-gutters class="mt-2">
            <b-col class="" cols="12" md="4">
              <ul>
                <li>Wyjątkowe postacie</li>
                <li>Masa narzędzi zagłady</li>
              </ul>
            </b-col>
            <b-col cols="12" md="4" class="">
              <ul>
                <li>Różnorodne klasy</li>
                <li>Wymagający bossowie</li>
              </ul>
            </b-col>
            <b-col cols="12" md="4" class="">
              <ul>
                <li>Wyjątkowy system walki</li>
                <li>Dziesiątki przeciwników</li>
              </ul>
            </b-col>
          </b-row>
          <div class="pixel" @click="$router.push('/download')">
            <p>Pobierz</p>
          </div>
        </span>
      </b-col>
      <b-col
        cols="8"
        md="4"
        lg="4"
        style="position: relative"
        order-md="1"
        order="2"

      >
        <b-img
          src="../assets/mage.png"
          fluid
          center
          style="position: relative"
        ></b-img>
      </b-col>
    </b-row>
  </div>
</template>

<style scoped>
.wrapper {
  width: 100%;
  overflow: hidden;
  height: calc(100vh - 600px);
  margin-top: -56px;
  z-index: -1;
}
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
}
.gradient {
  background: rgb(128, 30, 30);
  background: -moz-linear-gradient(
    180deg,
    rgba(128, 30, 30, 0.2819502801120448) 47%,
    rgba(84, 19, 19, 0.8757878151260504) 100%
  );
  background: -webkit-linear-gradient(
    180deg,
    rgba(128, 30, 30, 0.2819502801120448) 47%,
    rgba(84, 19, 19, 0.8757878151260504) 100%
  );
  background: linear-gradient(
    180deg,
    rgba(128, 30, 30, 0.2819502801120448) 47%,
    rgba(84, 19, 19, 0.8757878151260504) 100%
  );
  filter: progid:DXImageTransform.Microsoft.gradient(startColorstr="#801e1e",endColorstr="#541313",GradientType=1);
  opacity: 0.8;
  width: 100%;
  height: calc(100vh - 600px);
  object-fit: cover;
  position: relative;
  z-index: 0;
}

.bg-vid {
  top: 0;
  z-index: 0;
  width: 100%;
  height: calc(100vh - 600px);
  object-fit: cover;
  position: absolute;
}

.kokarda {
  animation: float 6s ease-in-out infinite;
  z-index: 2;
}
ul {
  list-style: none;
  padding: 0;
}

.pixel {
  font-size: 22px;
  color: white;
  height: auto;
  margin: 10px;
  font-family: "Impostor", Helvetica, Arial;

  position: relative;
  display: inline-block;
  vertical-align: top;
  text-transform: uppercase;

  cursor: pointer;

  -webkit-touch-callout: none;
  -webkit-user-select: none;
  -khtml-user-select: none;
  -moz-user-select: none;
  -ms-user-select: none;
  user-select: none;

  line-height: 0;

  image-rendering: optimizeSpeed;
  image-rendering: -moz-crisp-edges; /* Firefox */
  image-rendering: -o-crisp-edges; /* Opera */
  image-rendering: -webkit-optimize-contrast; /* Webkit (non-standard naming) */
  image-rendering: crisp-edges;
  -ms-interpolation-mode: nearest-neighbor; /* IE (non-standard property) */

  border-style: solid;
  border-width: 20px;
  -moz-border-image: url(https://i.imgur.com/sREM8Yn.png) 20 stretch;
  -webkit-border-image: url(https://i.imgur.com/sREM8Yn.png) 20 stretch;
  -o-border-image: url(https://i.imgur.com/sREM8Yn.png) 20 stretch;
  border-image: url(https://i.imgur.com/sREM8Yn.png) 20 stretch;
}
.pixel p {
  display: inline-block;
  vertical-align: top;
  position: relative;
  width: auto;
  text-align: center;
  margin: -20px -20px;
  line-height: 20px;
  padding: 15px 20px;

  background: #000000;
  background: linear-gradient(135deg, transparent 10px, #000000 0) top left,
    linear-gradient(225deg, transparent 10px, #000000 0) top right,
    linear-gradient(315deg, transparent 10px, #000000 0) bottom right,
    linear-gradient(45deg, transparent 10px, #000000 0) bottom left;
  background-size: 50% 50%;
  background-repeat: no-repeat;
  background-image: radial-gradient(
      circle at 0 0,
      rgba(204, 0, 0, 0) 14px,
      #000000 15px
    ),
    radial-gradient(circle at 100% 0, rgba(204, 0, 0, 0) 14px, #000000 15px),
    radial-gradient(circle at 100% 100%, rgba(204, 0, 0, 0) 14px, #000000 15px),
    radial-gradient(circle at 0 100%, rgba(204, 0, 0, 0) 14px, #000000 15px);
}

.pixel:active {
  top: 2px;
}
@keyframes float {
  0% {
    transform: translatey(calc(-40%));
  }
  50% {
    transform: translatey(calc(-40% - 20px));
  }
  100% {
    transform: translatey(calc(-40%));
  }
}
</style>