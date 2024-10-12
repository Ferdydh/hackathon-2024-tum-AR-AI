import { Friend, useDeleteFriend } from "@/api/api";
import {
  Card,
  CardContent,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Cross1Icon } from "@radix-ui/react-icons";
import EditFriendDialog from "./EditFriendDialog";
import { Button } from "./ui/button";
import { Chip } from "./ui/chip";
import { XIcon } from "lucide-react";

type FriendCardProps = {
  friend: Friend;
  onRemove?: () => void;
  setFriend: (friend: Friend) => void;
};

const FriendCard = ({ friend, onRemove, setFriend }: FriendCardProps) => {
  const { name, details } = friend;
  const { mutateAsync } = useDeleteFriend();

  const handleRemove = () => {
    setFriend({});
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
      <CardFooter>
        <Button variant="destructive" onClick={handleRemove}>
          <XIcon className="size-4" />
        </Button>
        <EditFriendDialog friend={friend} setFriend={setFriend} />
      </CardFooter>
    </Card>
  );
};

export default FriendCard;
