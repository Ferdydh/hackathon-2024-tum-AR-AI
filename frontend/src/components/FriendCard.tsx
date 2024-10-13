import { Friend, useDeleteFriend } from "@/api/api";
import {
  Card,
  CardContent,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Cross1Icon } from "@radix-ui/react-icons";
import { TrashIcon } from "lucide-react";
import { SetStateAction } from "react";
import EditFriendDialog from "./EditFriendDialog";
import { Button } from "./ui/button";
import { Chip } from "./ui/chip";

type FriendCardProps = {
  friend: Friend;
  onRemove?: () => void;
  setFriend: (value: SetStateAction<Friend | undefined>) => void;
};

const FriendCard = ({ friend, onRemove, setFriend }: FriendCardProps) => {
  const { name, details } = friend;
  const { mutateAsync } = useDeleteFriend();

  const handleRemove = () => {
    if (onRemove) onRemove();
    mutateAsync(friend?.id || "");
  };

  return (
    <Card>
      <CardHeader className="flex flex-row space-x-8 justify-between">
        <CardTitle>{name}</CardTitle>
        {onRemove && (
          <Button
            variant="ghost"
            size="icon"
            onClick={onRemove}
            className="size-4"
          >
            <Cross1Icon />
          </Button>
        )}
      </CardHeader>
      <CardContent>
        {details &&
          details.map((detail, index) => (
            <Chip key={index} text={detail} variant="outline">
              {detail}
            </Chip>
          ))}
      </CardContent>
      <CardFooter className="space-x-4">
        <Button variant="destructive" onClick={handleRemove}>
          <TrashIcon className="size-4" />
        </Button>
        <EditFriendDialog friend={friend} setFriend={setFriend} />
      </CardFooter>
    </Card>
  );
};

export default FriendCard;
