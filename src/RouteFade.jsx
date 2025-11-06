import { useLocation } from 'react-router-dom';

/** Wrap your Routes with this for a smooth fade on route changes */
export default function RouteFade({ children }) {
  const { pathname } = useLocation();
  return <div key={pathname} className="route-fade">{children}</div>;
}
