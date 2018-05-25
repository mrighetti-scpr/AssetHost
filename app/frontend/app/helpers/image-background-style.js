import { helper } from '@ember/component/helper';
import { htmlSafe } from '@ember/string';

function translatePosition(position){
  switch(position){
    case 'NorthWest':
      return 'top left';
    case 'West':
      return 'left';
    case 'SouthWest':
      return 'bottom left';
    case 'North':
      return 'top';
    case 'South':
      return 'bottom';
    case 'NorthEast':
      return 'top right';
    case 'East':
      return 'right';
    case 'SouthEast':
      return 'bottom right';
    default:
      return position || 'center';
  }
}

export function imageBackgroundStyle([url, position]) {
  if(url) return htmlSafe(`background-image: url(${url}); 
                           background-position: ${translatePosition(position)}; 
                           background-size: cover;`);
}

export default helper(imageBackgroundStyle);
