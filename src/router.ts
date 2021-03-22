import Vue from 'vue';
import Router from 'vue-router';

Vue.use(Router);

export default new Router({
  routes: [
    {
      path: '/',
      name: 'home',
      component: () =>
        import(/* webpackChunkName: "home" */ './views/Home.vue'),
    },{
      path: '/download',
      name: 'download',
      component: () =>
        import(/* webpackChunkName: "home" */ './views/Download.vue'),
    },
    {
      path: '/news',
      name: 'news',
      component: () =>
        import(/* webpackChunkName: "news" */ './views/News.vue'),
    },
    {
      path: '/wiki',
      name: 'wikia',
      component: () =>
        import(/* webpackChunkName: "home" */ './views/Home.vue'),
    },
    {
      path: '/team',
      name: 'team',
      component: () =>
        import(/* webpackChunkName: "home" */ './views/About.vue'),
    },
    { path: '*', redirect: '/404' },
  ],
  scrollBehavior(to, from, savedPosition) {
    if (savedPosition) {
      return savedPosition;
    } else {
      return { x: 0, y: 0 };
    }
  },
});
