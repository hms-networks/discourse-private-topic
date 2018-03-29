import showModal from 'discourse/lib/show-modal';
import { ajax } from 'discourse/lib/ajax';

export default {
  shouldRender(args, component) {
    if(args.model.custom_fields.topic_restricted_access === undefined){
      return false;
    }
    return args.model.custom_fields.topic_restricted_access;
  }
};
