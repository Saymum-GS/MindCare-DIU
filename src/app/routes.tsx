import { createBrowserRouter } from "react-router";
import { LandingPage } from "./pages/LandingPage";
import { RegisterPage } from "./pages/RegisterPage";
import { SignInPage } from "./pages/SignInPage";
import { OnboardingFlow } from "./pages/OnboardingFlow";
import { Dashboard } from "./pages/Dashboard";
import { ScreeningSelector } from "./pages/ScreeningSelector";
import { ScreeningQuestions } from "./pages/ScreeningQuestions";
import { ScreeningResults } from "./pages/ScreeningResults";
import { ContentLibrary } from "./pages/ContentLibrary";
import { ContentDetail } from "./pages/ContentDetail";
import { MoodTracker } from "./pages/MoodTracker";
import { PsychologistDirectory } from "./pages/PsychologistDirectory";
import { BookingFlow } from "./pages/BookingFlow";
import { CrisisKit } from "./pages/CrisisKit";
import { ProfileSettings } from "./pages/ProfileSettings";
import { MainLayout } from "./layouts/MainLayout";

export const router = createBrowserRouter([
  {
    path: "/",
    element: <LandingPage />,
  },
  {
    path: "/register",
    element: <RegisterPage />,
  },
  {
    path: "/signin",
    element: <SignInPage />,
  },
  {
    path: "/onboarding",
    element: <OnboardingFlow />,
  },
  {
    path: "/crisis",
    element: <CrisisKit />,
  },
  {
    element: <MainLayout />,
    children: [
      {
        path: "/dashboard",
        element: <Dashboard />,
      },
      {
        path: "/screening",
        element: <ScreeningSelector />,
      },
      {
        path: "/screening/:type",
        element: <ScreeningQuestions />,
      },
      {
        path: "/screening/results/:type",
        element: <ScreeningResults />,
      },
      {
        path: "/content",
        element: <ContentLibrary />,
      },
      {
        path: "/content/:id",
        element: <ContentDetail />,
      },
      {
        path: "/mood",
        element: <MoodTracker />,
      },
      {
        path: "/psychologists",
        element: <PsychologistDirectory />,
      },
      {
        path: "/booking/:psychologistId",
        element: <BookingFlow />,
      },
      {
        path: "/profile",
        element: <ProfileSettings />,
      },
    ],
  },
]);
