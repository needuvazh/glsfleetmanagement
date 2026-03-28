import { Toaster } from "@/components/ui/sonner";
import { TooltipProvider } from "@/components/ui/tooltip";
import NotFound from "@/pages/NotFound";
import { Route, Switch } from "wouter";
import ErrorBoundary from "./components/ErrorBoundary";
import { ThemeProvider } from "./contexts/ThemeContext";
import DashboardLayout from "./components/DashboardLayout";

// Pages
import Dashboard from "./pages/Dashboard";
import FleetManagement from "./pages/FleetManagement";
import DriverManagement from "./pages/DriverManagement";
import CustomerRequests from "./pages/CustomerRequests";
import Quotations from "./pages/Quotations";
import WorkOrders from "./pages/WorkOrders";
import Compliance from "./pages/Compliance";
import JourneyManagement from "./pages/JourneyManagement";
import TripExecution from "./pages/TripExecution";
import Delivery from "./pages/Delivery";
import Documents from "./pages/Documents";
import Invoice from "./pages/Invoice";
import Alerts from "./pages/Alerts";
import VehicleTypes from "./pages/VehicleTypes";
import Locations from "./pages/Locations";
import Routes from "./pages/Routes";
import DocumentManagement from "./pages/DocumentManagement";
import Roles from "./pages/Roles";
import Users from "./pages/Users";

function Router() {
  return (
    <DashboardLayout>
      <Switch>
        <Route path="/" component={Dashboard} />
        <Route path="/fleet" component={FleetManagement} />
        <Route path="/drivers" component={DriverManagement} />
        <Route path="/customer-requests" component={CustomerRequests} />
        <Route path="/quotations" component={Quotations} />
        <Route path="/work-orders" component={WorkOrders} />
        <Route path="/compliance" component={Compliance} />
        <Route path="/journey" component={JourneyManagement} />
        <Route path="/trip-execution" component={TripExecution} />
        <Route path="/delivery" component={Delivery} />
        <Route path="/documents" component={Documents} />
        <Route path="/invoice" component={Invoice} />
        <Route path="/alerts" component={Alerts} />
        <Route path="/vehicle-types" component={VehicleTypes} />
        <Route path="/locations" component={Locations} />
        <Route path="/routes" component={Routes} />
        <Route path="/document-management" component={DocumentManagement} />
        <Route path="/roles" component={Roles} />
        <Route path="/users" component={Users} />
        <Route path="/404" component={NotFound} />
        <Route component={NotFound} />
      </Switch>
    </DashboardLayout>
  );
}

function App() {
  return (
    <ErrorBoundary>
      <ThemeProvider defaultTheme="light">
        <TooltipProvider>
          <Toaster />
          <Router />
        </TooltipProvider>
      </ThemeProvider>
    </ErrorBoundary>
  );
}

export default App;
