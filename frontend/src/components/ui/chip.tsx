import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import { LucideIcon } from "lucide-react";
import React from "react";

interface ChipProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: "default" | "outline" | "secondary" | "ghost";
  icon?: LucideIcon;
  text: string;
}

export const Chip = React.forwardRef<HTMLButtonElement, ChipProps>(
  ({ className, variant = "default", icon: Icon, text, ...props }, ref) => {
    return (
      <Button
        ref={ref}
        variant={variant}
        className={cn(
          "h-7 rounded-full px-3 text-xs font-medium",
          variant === "default" &&
            "bg-primary/10 text-primary hover:bg-primary/20",
          variant === "secondary" &&
            "bg-secondary/10 text-secondary hover:bg-secondary/20",
          "flex items-center space-x-1",
          className
        )}
        {...props}
      >
        {Icon && <Icon className="h-3.5 w-3.5 mr-1" />}
        <span>{text}</span>
      </Button>
    );
  }
);
Chip.displayName = "Chip";
