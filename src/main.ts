import Vue from 'vue';
import './plugins/bootstrap-vue'
import App from './App.vue';
import router from './router';
import '@mdi/font/css/materialdesignicons.css';
import 'animate.css';
const Timeline = () => import(/* webpackChunkName: "timeline" */ './components/Timeline.vue');
const Newslist = () => import(/* webpackChunkName: "newslist" */ './components/Newslist.vue');
const Gallery = () => import(/* webpackChunkName: "gallery" */ './components/Gallery.vue');
const Testimonial = () => import(/* webpackChunkName: "gallery" */ './components/Testimonial.vue');

Vue.config.productionTip = false;

new Vue({
  router,
  render: (h) => h(App),
}).$mount('#app');


Vue.component('timeline', Timeline);
Vue.component('newslist', Newslist);
Vue.component('gallery', Gallery);
Vue.component('testimonial', Testimonial);