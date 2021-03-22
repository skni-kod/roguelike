<template>
  <div>
     <div class="background"></div>
    <b-row
      no-gutters
      class="text-light pb-5 mt-5"
      align-h="center"
      align-v="center"
    >
      <b-col cols="12" class='mb-5'
        ><b-img src="../assets/kokarda.png" center fluid class="kokarda"></b-img
      ></b-col>
      <b-col
        cols="12"
        md="6"
        lg="5"
        order-md="2"
        order="1"
        class="pb-5 text-center mt-5"
      >
        <div class="pixel2 p-3">Dolacz juz teraz!</div>
      </b-col>
    </b-row>
    <gallery></gallery>
  </div>
</template>

<style scoped>
.pixel2 {
  font-size: 25px;
  color: white;
  height: auto;
  margin: 10px;
  font-family: "Impostor", Helvetica, Arial;
  line-height: 70px;

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
}
.pixel2::before {
  content: "";
  display: block;
  position: absolute;
  top: 10px;
  bottom: 10px;
  left: -10px;
  right: -10px;
  background: rgb(0, 0, 0, 0.3);
  z-index: -1;
}

.pixel2::after {
  content: "";
  display: block;
  position: absolute;
  top: 4px;
  bottom: 4px;
  left: -6px;
  right: -6px;
  background: rgb(0, 0, 0, 0.3);
  z-index: -1;
}
.pixel2:active {
  top: 2px;
}
.pixel2 {
  padding: 10px 10px;
  position: relative;
  background: rgb(0, 0, 0, 0.3);
  width: auto;
  z-index: 2;
}

div.background {
  background: url("../assets/tlo_download.png");
  background-repeat: no-repeat;
  background-size: cover;
  position: absolute;
  width: 100vw;
  height: 100vh;
  margin: 0;
  top: 0;
  left: 0;
  position: fixed;
}
.wrapper {
  width: 100%;
  overflow: hidden;
  height: calc(100vh - 600px);
  margin-top: -56px;
  z-index: -1;
}
.gradient {
  background: rgb(52, 58, 64);
  background: -moz-linear-gradient(
    0deg,
    rgba(52, 58, 64, 0.8225665266106442) 27%,
    rgba(0, 0, 0, 0.28755252100840334) 100%
  );
  background: -webkit-linear-gradient(
    0deg,
    rgba(52, 58, 64, 0.8225665266106442) 27%,
    rgba(0, 0, 0, 0.28755252100840334) 100%
  );
  background: linear-gradient(
    0deg,
    rgba(52, 58, 64, 0.8225665266106442) 27%,
    rgba(0, 0, 0, 0.28755252100840334) 100%
  );
  filter: progid:DXImageTransform.Microsoft.gradient(startColorstr="#343a40",endColorstr="#000000",GradientType=1);
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
  z-index: 2;
}

.hero::before {
  position: absolute;
  left: calc(50% - 10vw);
  bottom: calc(50% - 16vh);
  width: 80%;
  z-index: 0;
  height: 80%;
  clip-path: circle(43% at 50% 50%);
  background: rgb(255, 255, 255, 0.2);
  content: "";
}

ul {
  list-style: none;
  padding: 0;
}

.gallery > div > img {
  position: relative;
}
.gallery > div > img:hover {
  transform: scale(1.1);
  z-index: 1;
  transition: 0.3s;
  cursor: pointer;
}

@media screen and (max-width: 1277px) {
  .hero::before {
    display: none;
  }
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