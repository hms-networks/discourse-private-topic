//import { default as computed } from 'ember-addons/ember-computed-decorators';
import { ajax } from 'discourse/lib/ajax';
import { popupAjaxError } from 'discourse/lib/ajax-error';
import { withPluginApi } from 'discourse/lib/plugin-api';

export default Ember.Controller.extend({
  actions: {
    controlAccess(){
       //? false : true;
      return ajax("/privatetopic/control_access",{
       type: 'POST',
       data: { access_allowed: this.get('model.restrictedAccess'), topic_id: this.get('model.topic.id') }
     }).then(()=>{
       window.location.reload();
     }).catch(popupAjaxError);
    }
  }
});
