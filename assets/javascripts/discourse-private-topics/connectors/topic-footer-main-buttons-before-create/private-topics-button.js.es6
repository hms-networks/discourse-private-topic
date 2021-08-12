import showModal from 'discourse/lib/show-modal';
import { ajax } from 'discourse/lib/ajax';

export default {
  shouldRender(args, component) {
    return component.currentUser && component.currentUser.staff;
  },

  actions: {
    controlAccess(){
      const container = Discourse.__container__;
      let restrictedAccess = !this.topic.get('custom_fields.topic_restricted_access');
       var model =  {
        topic: this.topic,
        restrictedAccess: restrictedAccess
        }
      let controller = container.lookup('controller:private-topics');
      controller.set('model', model);
      controller.send('controlAccess');
    }
  }
};
