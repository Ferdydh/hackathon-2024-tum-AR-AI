"use client";

import { Friend, useUpdateFriend } from "@/api/api";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Edit2Icon, PlusCircle, X } from "lucide-react";
import { useState } from "react";

interface FriendForm {
  name: string;
  details: string[];
}

type FriendEditorProps = {
  friend: Friend;
  setFriend: (friend: Friend) => void;
};

export default function FriendEditor({
  friend: oldFriend,
  setFriend: updateFriendCard,
}: FriendEditorProps) {
  const [isOpen, setIsOpen] = useState(false);
  const [friend, setFriend] = useState<FriendForm>({
    name: oldFriend?.name || "",
    details: oldFriend?.details || [""],
  });
  const { mutateAsync } = useUpdateFriend();

  const handleNameChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setFriend((prev) => ({ ...prev, name: e.target.value }));
  };

  const handleDetailChange = (index: number, value: string) => {
    setFriend((prev) => {
      const newDetails = [...prev.details];
      newDetails[index] = value;
      return { ...prev, details: newDetails };
    });
  };

  const addDetail = () => {
    setFriend((prev) => ({ ...prev, details: [...prev.details, ""] }));
  };

  const removeDetail = (index: number) => {
    setFriend((prev) => {
      const newDetails = prev.details.filter((_, i) => i !== index);
      return { ...prev, details: newDetails };
    });
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (oldFriend?.id) {
      mutateAsync({
        id: oldFriend.id,
        friend: { name: friend.name, details: friend.details },
      }).then(() => {
        setIsOpen(false);
        updateFriendCard({
          ...oldFriend,
          name: friend.name,
          details: friend.details,
        });
      });
    }
  };

  return (
    <Dialog open={isOpen} onOpenChange={setIsOpen}>
      <DialogTrigger asChild>
        <Button variant="outline">
          <Edit2Icon />
        </Button>
      </DialogTrigger>
      <DialogContent className="sm:max-w-[425px]">
        <DialogHeader>
          <DialogTitle>Edit Friend Details</DialogTitle>
        </DialogHeader>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="space-y-2">
            <Label htmlFor="name">Name</Label>
            <Input
              id="name"
              value={friend.name}
              onChange={handleNameChange}
              placeholder="Enter friend's name"
            />
          </div>
          <div className="space-y-2">
            <Label>Details</Label>
            {friend.details.map((detail, index) => (
              <div key={index} className="flex items-center space-x-2">
                <Input
                  value={detail}
                  onChange={(e) => handleDetailChange(index, e.target.value)}
                  placeholder={`Detail ${index + 1}`}
                />
                <Button
                  type="button"
                  variant="ghost"
                  size="icon"
                  onClick={() => removeDetail(index)}
                >
                  <X className="h-4 w-4" />
                </Button>
              </div>
            ))}
            <Button
              type="button"
              variant="outline"
              size="sm"
              className="mt-2"
              onClick={addDetail}
            >
              <PlusCircle className="h-4 w-4 mr-2" />
              Add Detail
            </Button>
          </div>
          <Button type="submit" className="w-full">
            Save Changes
          </Button>
        </form>
      </DialogContent>
    </Dialog>
  );
}
