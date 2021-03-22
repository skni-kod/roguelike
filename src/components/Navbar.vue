<template>
  <div>
    <b-navbar toggleable="lg" type="dark" style=';z-index:1'>
      <b-col xl="6" cols='2' align='center'>
      <b-navbar-brand>ROGUELIKE</b-navbar-brand>
      </b-col>
      <b-navbar-toggle target="nav-collapse"></b-navbar-toggle>

      <b-collapse id="nav-collapse" is-nav>
        <b-navbar-nav>
          <b-nav-item
            v-for="item in items"
            :key="item.name"
            :to="item.link"
            :active='$route.path == item.link'
            ><b-icon :icon="item.icon"></b-icon> {{ item.name }}</b-nav-item
          >
        </b-navbar-nav>
      </b-collapse>
    </b-navbar>
  </div>
</template>


<script lang="ts">
import { Component } from "vue-property-decorator";
import Vue from "vue";
@Component({})
export default class Navbar extends Vue {
  data() {
    return {
      items: [
        { name: "Strona główna", link: "/", icon: "house"},
        { name: "Pobierz", link: "/download", icon:"arrow-down" },
        { name: "Aktualności", link: "/news", icon:"newspaper" },
        //{ name: "Wikia", link: "/wiki", icon:"controller" },
        { name: "O nas", link: "/team", icon:"person" },
      ],
    };
  }
}
</script>
